-Dlog4j.configurationFile=conf/log4j2.xml
s.u.AsyncExecutor - Having maxConnection > maxThreads can result in deadlocks if transactions or database locks are used.
https://github.com/slick/slick/blob/master/slick/src/main/scala/slick/util/AsyncExecutor.scala
https://github.com/playframework/play-slick/issues/445
slick.dbs.default.db.numThreads = 100
slick.dbs.default.db.maxConnections = 100

