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
  updated_at: String,
  mergeable: Boolean
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

object Main {
  implicit val formats = DefaultFormats // Brings in default date formats etc.

  val urlpath = "http://github.com/api/v2/json/pulls/scala/scala/open"
  val url     = new java.net.URL(urlpath)
  val req     = slurp(url)
  val json    = parse(slurp(url))

  def pulls    = (json \ "pulls").extract[List[Pull]].sorted
  def shas     = pulls map (_.sha10)
  def refs     = pulls map (_.ref)
  def users    = pulls map (_.user)
  def branches = pulls map (_.branch)
  // def fields(key: String) = (json \\ "head" \\ key children) map (_.extract[String])
  
  def pp() {
    Process("jsonpp") #< new StringBufferInputStream(req) !
  }
  def showPulls() {
    pulls foreach {
      case pull @ Pull(number, Commit(sha, label, ref, repository), user, title, updated_at, mergeable) =>
        println("%3d  %10s  %8s  %-40s  %10s  %s".format(
          number, sha take 10, user.login take 8, title take 40, pull.date, ref))
    }
    println("")
    println(branches.mkString("git merge ", " ", ""))
    println("")
    println(shas.mkString("git merge ", " ", ""))
  }
      
  def main(args: Array[String]): Unit = {
    if (args.isEmpty) {
      println("Usage: pullreqs <cmds>")
      println("  Cmds: pp, pulls\n")
      showPulls()
    }
    else args foreach {
      case "pp"     => pp()
      case "pulls"  => showPulls()
    }
  }
}
