# running java
#

jutilsJavaHome=""
jutilsJavaOpts=""
jutilsJavaPath="java"
jutilsExtraJavaSource=""

java-home () {
     [[ -n "$JAVA_HOME" ]] && echo "$JAVA_HOME" \
  || program-home java \
  || true
}
java-property () {
  run-java-expr "System.getProperty(\"$1\")"
}

run-javac () {
  jlog "[run-javac] javac -d . -cp $jutilsClasspath $jutilsJavacOpts" "$@"

  javac -d . -cp $jutilsClasspath $jutilsJavacOpts "$@"
}
run-java () {
  jlog "[run-java] java -cp $jutilsClasspath $jutilsJavaOpts" "$@"

  java -cp $jutilsClasspath $jutilsJavaOpts "$@" 
}

# Wraps the expression, compiles, runs.
run-java-expr () {
  run-java-method "return \"\" + ($@);"
}

# Takes the arguments a method body returning String.
# Compiles, calls the method, prints result.
run-java-method () {
  local file=$(wrap-java-method "$@")
  local dir=$(dirname "$file")
  local base=$(basename "$file")
  local name="${base%%.java}"

  ( cd "$dir" && append-classpath "$dir" && run-javac "$file" && run-java "jutils.$name" )
}

wrap-java-method () {
  local dir=$(mktemp -d -t jutils)
  local name="jutils$RANDOM"
  local file="$dir/$name.java"
  jlog "[wrap-java-expr] $file"

  cat >"$dir/${name}.java" <<EOM
package jutils;
import java.io.File;

$jutilsExtraJavaSource

public class $name {
  private static String apply() throws Throwable {
    $@
  }
  public static void main(String[] args) throws Throwable {
    try {
      System.out.println(apply());
    }
    catch(NullPointerException t) {
      System.exit(0); // don't fail
    }
    catch(Throwable t) {
      throw t;
    }
  }
}
EOM

  echo "$file"
}

whereClassSource () {
  cat <<EOM
class WhereClass {
  String find() { 
    return find(this.getClass());
  }
  String find(String className) {
    try {
      return find(Class.forName(className));
    }
    catch(ClassNotFoundException e) {
      return null;
    }
  }
  String find(Class<?> clazz) {
    String name = clazz.getName().replace('.', '/');
    String s = clazz.getResource("/" + name + ".class").toString();
    s = s.replace('/', File.separatorChar);
    int start = s.indexOf(File.separatorChar);
    int end = s.indexOf(".jar") + 4;
    
    return s.substring(start, end);
  }
  String findAll(String... args) {
    for (int i = 0; i < args.length; i++) {
      String s = find(args[i]);
      if (s != null)
        System.out.println(s);
    }
    return "";
  }
}
EOM
}
