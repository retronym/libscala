logLevel := Level.Warn

scalaVersion := "2.10.0"

// resolvers += Opts.resolver.sonatypeSnapshots

libraryDependencies ++= Seq(
  "net.liftweb" %% "lift-json" % "2.5-M4"
)

retrieveManaged := true
