logLevel := Level.Warn

scalaVersion := "2.10.2"

libraryDependencies ++= Seq(
  "net.liftweb" %% "lift-json" % "2.5-M4",
  "org.scala-lang" % "scala-compiler" % scalaVersion.value
)

retrieveManaged := true
