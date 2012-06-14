package improving
package pullreq

import net.liftweb.json.{ DefaultFormats }
import net.liftweb.json.JsonParser._
import scala.tools.nsc.io.Streamable.slurp
import java.io.StringBufferInputStream
import scala.sys.process._
import java.net.URL

trait HasSha {
  def sha: String
  def sha10: String = sha take 10
}

case class Commit(
  url: String,
  sha: String,
  author: User,
  committer: User,
  message: String,
  tree: Tree,
  parents: List[Tree]
) extends HasSha {
}
case class Tree(
  url: String,
  sha: String
) extends HasSha {
}

case class User(
  login: String,
  id: String,
  name: Option[String],
  email: Option[String]
)

case class Repo(
  name: String,
  full_name: String,  // e.g. scala/scala
  html_url: String
)

case class Pull(
  number: Int,
  state: String,
  base: Ref,
  head: Ref,
  user: User,
  title: String,
  body: String,
  created_at: String,
  updated_at: String
  // Not given in the "list" mode, only for individual pullreqs
  // mergeable: Option[Boolean]
) extends Ordered[Pull] {
  def isOpen = state == "open"
  // def isNotMergeable = mergeable exists (x => !x)
  // def isMergeable = mergeable exists (x => x)
  def compare(other: Pull): Int = number compare other.number
  def sha        = head.sha10
  def branch     = head.userAndBranch
  def created    = created_at takeWhile (_ != 'T')
  def updated    = updated_at takeWhile (_ != 'T')
  def shortTitle = if (title.length <= 60) title else (title take 57).trim + "..."
}

case class Ref(
  repo: Repo,
  user: Option[User],
  sha: String,
  ref: String,
  label: String
) extends HasSha {
  def userAndBranch = label.replace(':', '/')
}

class PullReqs(userAndRepo: String) {
  implicit val formats = DefaultFormats // Brings in default date formats etc.

  val urlpath = "https://api.github.com/repos/" + userAndRepo + "/pulls"
  // val oauth   = "?access_token=" + sys.env("GITHUB_TOKEN")
  val url     = new java.net.URL(urlpath)
  val jsonRaw = slurp(url)
  val json    = parse(slurp(url))

  def pulls    = json.extract[List[Pull]].sorted
  def numbers  = pulls map (_.number)
  def branches = pulls map (_.branch)
  // def fields(key: String) = (json \\ "head" \\ key children) map (_.extract[String])
  
  def pp() = Process("jsonpp") #< new StringBufferInputStream(jsonRaw) !
  def showPulls() {
    pulls foreach { p =>
      println("%3d  %10s  %-15s  %-60s".format(p.number, p.created, p.user.login, p.shortTitle))
    }
    println(branches.mkString("\ngit merge ", " ", ""))
    println(numbers map ("refs/pull/" + _ + "/head") mkString ("\ngit merge ", " ", ""))
  }
}

object Main {
  def main(args: Array[String]): Unit = {
    args.toList match {
      case userAndRepo :: args =>
        val req = new PullReqs(userAndRepo)

        if (args.isEmpty) req.showPulls()
        else args foreach {
          case "pp"     => req.pp()
          case "pulls"  => req.showPulls()
        }
      case args =>
        println("Usage: pullreqs user/repo [pp | pulls]")
        println("  Example: pullreqs scala/scala\n")
    }
  }
}
