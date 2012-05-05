package improving
package pullreq

import net.liftweb.json.{ DefaultFormats }
import net.liftweb.json.JsonParser._
import scala.tools.nsc.io.Streamable.slurp
import java.io.StringBufferInputStream
import scala.sys.process._
import java.net.URL

case class User(
  login: String,
  name: Option[String],
  email: Option[String],
  repository: Option[Repository]
)

case class Repository(
  name: String,
  owner: String,
  url: String
)

case class Pull(
  number: Int,
  head: Commit,
  user: User,
  title: String,
  updated_at: String
  // mergeable: Boolean
) extends Ordered[Pull] {
  def compare(other: Pull): Int = number compare other.number
  def sha10  = head.sha10
  def ref    = head.ref
  def branch = head.label.replace(':', '/')
  def date   = updated_at takeWhile (_ != 'T')
  def time   = updated_at drop (date.length + 1)
}

case class Commit(
  sha: String,
  label: String,
  ref: String,
  repository: Repository
) {
  def sha10 = sha take 10
}

class PullReqs(userAndRepo: String) {
  implicit val formats = DefaultFormats // Brings in default date formats etc.

  val urlpath = "http://github.com/api/v2/json/pulls/" + userAndRepo + "/open"
  // val oauth   = "?access_token=" + sys.env("GITHUB_TOKEN")
  val url     = new java.net.URL(urlpath)
  val jsonRaw     = slurp(url)
  val json    = parse(slurp(url))

  def pulls    = (json \ "pulls").extract[List[Pull]].sorted
  def shas     = pulls map (_.sha10)
  def numbers  = pulls map (_.number)
  def refs     = pulls map (_.ref)
  def users    = pulls map (_.user)
  def branches = pulls map (_.branch)
  // def fields(key: String) = (json \\ "head" \\ key children) map (_.extract[String])
  
  def pp() = Process("jsonpp") #< new StringBufferInputStream(jsonRaw) !
  def showPulls() {
    pulls foreach {
      case pull @ Pull(number, Commit(sha, label, ref, repository), user, title, updated_at) =>
        println("%3d  %10s  %-15s  %-60s".format(number, pull.date, user.login, title take 60))
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
        println(req.urlpath)

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
