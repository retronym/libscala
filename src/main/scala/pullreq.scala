package improving
package pullreq

import net.liftweb.json.{ DefaultFormats }
import net.liftweb.json.JsonParser._
import scala.tools.nsc.io.Streamable.slurp
import java.io.StringBufferInputStream
import scala.sys.process._
import java.net.URL

// 
// "user": {
//   "name": "Ismael Juma",
//   "company": "LikeCube",
//   "gravatar_id": "0eb053bf15b0a3669c973bc50be45a7c",
//   "location": "London, UK",
//   "blog": "http://blog.juma.me.uk",
//   "type": "User",
//   "login": "ijuma",
//   "email": "mlists@juma.me.uk"
// },
  // 
  // company: Option[String],
  // gravatar_id: Option[String],
  // location: Option[String],
  // // blog: URL,
  // blog: Option[String],

case class User(
  login: String,
  name: Option[String],
  email: Option[String]
)

object Main {
  implicit val formats = DefaultFormats // Brings in default date formats etc.

  val urlpath = "http://github.com/api/v2/json/pulls/scala/scala/open"
  val url  = new java.net.URL(urlpath)
  val req  = slurp(url)
  val json = parse(slurp(url))

  def fields(key: String) = (
    (json \\ "head" \\ key children) map (_.extract[String])
  )
  def shas = fields("sha")
  def refs = fields("ref")
  def users = (json \ "pulls" \ "user").extract[List[User]]
  def branches = (users, refs).zipped map (_.login + "/" + _)
  
  def pp() {
    Process("jsonpp") #< new StringBufferInputStream(req) !
  }
  def pulls() {
    println(branches.mkString("git merge ", " ", ""))
  }

  def main(args: Array[String]): Unit = {
    if (args.isEmpty) pulls()
    else args foreach {
      case "pp"     => pp()
      case "pulls"  => pulls()
    }
  }
}


// import scala.tools.nsc.io.Streamable.slurp
// import com.codahale.jerkson.Json._
// // type JMap[V] = java.util.LinkedHashMap[String, V]
// type JMap[V] = Map[String, V]
// type ListM   = List[JMap[Any]]
// type MListM  = JMap[ListM]
// 
// def asListM(body: => String): ListM = parse[ListM](body)
// def asMap[V](body: => Any): JMap[V] = body.asInstanceOf[JMap[V]]
// def asSMap(body: => Any) = asMap[String](body)
// def asMMap(body: => Any) = asMap[JMap[Any]](body)
// 
// def merge[T](items: List[Map[String, T]]): Map[String, List[T]] = {
//   val keys = items flatMap (_.keys) distinct;
//   
//   keys map (k => (k, items flatMap (_ get k) distinct)) toMap
// }
// 
// val url      = "http://github.com/api/v2/json/pulls/scala/scala/open"
// val map      = parse[MListM](slurp(new java.net.URL(url)))
// val pullMap  = merge(map("pulls"))
// val headMap  = merge(pullMap("head"))
// 
// val pulls    = map("pulls")
// val pullKeys = pulls flatMap (_.keys) distinct;
// val pullMap  = pullKeys map (k => (k, pulls flatMap (_ get k))) toMap;
// 
// val heads = asMMap {
//   
// 
// pullMap("head")