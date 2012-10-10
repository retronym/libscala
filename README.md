Tools for scala developers.  I have a lot more but it is going to take
me some time to organize everything.

Add lines like these to your .profile or similar:

    export SCALA_SRC_HOME=/path/to/repo  # path to a scratch checkout of trunk
    export SCALA_PACKS_DIR=/path/to/dir  # path to somewhere to cached downloaded builds
    source /path/to/libscala.sh

Run this one time:

    ./git-java/install.sh

If you're lucky, that's it.  Examples of available things:

    gh-commit <sha|svn> # accepts sha-1 or rev, shows in browser.  Tab-completion on svn revs!
    java -XX:           # tab-completion on java -XX: options (a tad verbose at the moment)
    scala -J-XX:        # also completes on -J-XX: options
    gco <tab>           # a git checkout which completes on local branches only
    gh-find Global      # open a browser to those files in trunk matching Global

There are a number of git-XXX wrappers in ~/bin, e.g.

    git-diff-grep b1 b2 Bippy     # Show a diff between b1 and b2 - but only the hunks containing "Bippy"

If you have a lot of git branches tied to a non-canonical version of the
scala repository, you might want to look at git-remaster, which can fix that
all up for you.

There is an sbt project in github-api which provides the basis for "pullreqs",
a command you can run from (any project's) github clone to see something like this:

    % pullreqs

     49  365c9bb163       soc  Migration improvements                    2012-01-09  SI-4990#2
     82  51667dc039  erikroze  Immutable TreeMap/TreeSet performance (S  2012-01-26  SI-5331
    124  dce6b34c38  stephenj  Fixes SI-4929, with a test to verify.     2012-01-22  SI-4929-2
    136  372bfc4717  dcsobral  Regex improvements                        2012-01-25  SI-2460
    137  2ddee14899  LannyRip  SI-5045 Regex.unapplySeq should use m.fi  2012-01-25  master
    139  6972dc556c  dcsobral  Document regex replacement strings behav  2012-01-25  SI-4750
    142  1cb962518e  dcsobral  Add a split method with limit to Regex.   2012-01-25  SI-5088
    145  2df3934168  dcsobral  Performance improvements for CommentFact  2012-01-26  DocSpeed
    147  4224d2a7b0   xeno-by  -Yshow-symkinds: prints kinds next to sy  2012-01-28  topic/yshowsymkinds

    git merge soc/SI-4990#2 erikrozendaal/SI-5331 stephenjudkins/SI-4929-2 dcsobral/SI-2460 LannyRipple/master dcsobral/SI-4750 dcsobral/SI-5088 dcsobral/DocSpeed scalamacros/topic/yshowsymkinds

    git merge 365c9bb163 51667dc039 dce6b34c38 372bfc4717 2ddee14899 6972dc556c 1cb962518e 2df3934168 4224d2a7b0

The git-java part enables you to check jars and *.class files into a
git repository and see a useful diff.  After you run ./git-java/install.sh,
it will tell you to run git-java/demo.sh.  Do so.  You should see this:

```diff
diff --git c/A.class w/A.class
index eb57cde27f..ec9040dd7d 100644
--- c/A.class
+++ w/A.class
@@ -16,14 +16,19 @@ public final class A extends java.lang.Object implements scala.ScalaObject{
 public scala.Option f(int);
   Signature: (I)Lscala/Option;
   Code:
-##:    new     ###; //class A$$anonfun$f$##
-##:    dup
 ##:    iload_1
-##:    invokespecial   ###; //Method A$$anonfun$f$##."<init>":(LA;I)V
-##:    new     ###; //class A$$anonfun$f$##
+##:    iconst_5
+##:    if_icmple       ##
+##:    iconst_1
+##:    goto    ##
+##:    ifeq    ##
+##:    new     ###; //class scala/Some
 ##:    dup
 ##:    iload_1
-##:    invokespecial   ###; //Method A$$anonfun$f$##."<init>":(LA;I)V
+##:    invokestatic    ###; //Method scala/runtime/BoxesRunTime.boxToInteger:(I)Ljava/lang/Integer;
+##:    invokespecial   ###; //Method scala/Some."<init>":(Ljava/lang/Object;)V
+##:    goto    ##
+##:    getstatic       ###; //Field scala/None$.MODULE$:Lscala/None$;
 ##:    areturn
```

And for the hotspot junkie in your life:

```bash
% java -XX:<tab>
Display all 998 possibilities? (y or n)
% java -XX:+Print<tab>
-XX:+PrintAdaptiveSizePolicy              -XX:+PrintJavaStackAtFatalState
-XX:+PrintClassHistogram                  -XX:+PrintJNIGCStalls
-XX:+PrintClassHistogramAfterFullGC       -XX:+PrintJNIResolving
-XX:+PrintClassHistogramBeforeFullGC      -XX:+PrintOldPLAB
-XX:+PrintCMSInitiationStatistics         -XX:+PrintOopAddress
-XX:+PrintCommandLineFlags                -XX:+PrintParallelOldGCPhaseTimes
-XX:+PrintCompilation                     -XX:+PrintPLAB
-XX:+PrintConcurrentLocks                 -XX:+PrintPreciseBiasedLockingStatistics
-XX:+PrintFlagsFinal                      -XX:+PrintPromotionFailure
-XX:+PrintFlagsInitial                    -XX:+PrintReferenceGC
-XX:+PrintGC                              -XX:+PrintRevisitStats
-XX:+PrintGCApplicationConcurrentTime     -XX:+PrintSafepointStatistics
-XX:+PrintGCApplicationStoppedTime        -XX:+PrintSharedSpaces
-XX:+PrintGCDateStamps                    -XX:+PrintTenuringDistribution
-XX:+PrintGCDetails                       -XX:+PrintTieredEvents
-XX:+PrintGCTaskTimeStamps                -XX:+PrintTLAB
-XX:+PrintGCTimeStamps                    -XX:+PrintVMOptions
-XX:+PrintHeapAtGC                        -XX:+PrintVMQWaitTime
-XX:+PrintHeapAtGCExtended                -XX:+PrintWarnings
-XX:+PrintHeapAtSIGBREAK
```
