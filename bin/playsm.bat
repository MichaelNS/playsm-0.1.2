@REM playsm launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM PLAYSM_config.txt found in the PLAYSM_HOME.
@setlocal enabledelayedexpansion

@echo off


if "%PLAYSM_HOME%"=="" (
  set "APP_HOME=%~dp0\\.."

  rem Also set the old env name for backwards compatibility
  set "PLAYSM_HOME=%~dp0\\.."
) else (
  set "APP_HOME=%PLAYSM_HOME%"
)

set "APP_LIB_DIR=%APP_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (!cmdcmdline!) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%APP_HOME%\PLAYSM_config.txt"
set CFG_OPTS=
call :parse_config "%CFG_FILE%" CFG_OPTS

rem We use the value of the JAVACMD environment variable if defined
set _JAVACMD=%JAVACMD%

if "%_JAVACMD%"=="" (
  if not "%JAVA_HOME%"=="" (
    if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==java set JAVAINSTALLED=1
  if %%~j==openjdk set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running playsm.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)


rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "!_JAVA_OPTS!"=="" set _JAVA_OPTS=!CFG_OPTS!

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=
set _APP_ARGS=

set "APP_CLASSPATH=%APP_LIB_DIR%\..\conf\;%APP_LIB_DIR%\ru.ns.playsm-0.1.2-sans-externalized.jar;%APP_LIB_DIR%\ru.ns.fileutils-0.0.1.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.12.8.jar;%APP_LIB_DIR%\org.scoverage.scalac-scoverage-runtime_2.12-1.3.1.jar;%APP_LIB_DIR%\ch.qos.logback.logback-classic-1.2.3.jar;%APP_LIB_DIR%\ch.qos.logback.logback-core-1.2.3.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.25.jar;%APP_LIB_DIR%\com.typesafe.scala-logging.scala-logging_2.12-3.9.2.jar;%APP_LIB_DIR%\org.scala-lang.scala-reflect-2.12.8.jar;%APP_LIB_DIR%\com.roundeights.hasher_2.12-1.2.0.jar;%APP_LIB_DIR%\com.google.j2objc.j2objc-annotations-1.1.jar;%APP_LIB_DIR%\com.lihaoyi.sourcecode_2.12-0.1.5.jar;%APP_LIB_DIR%\com.lihaoyi.pprint_2.12-0.5.3.jar;%APP_LIB_DIR%\com.lihaoyi.fansi_2.12-0.2.5.jar;%APP_LIB_DIR%\org.json4s.json4s-native_2.12-3.6.4.jar;%APP_LIB_DIR%\org.json4s.json4s-core_2.12-3.6.4.jar;%APP_LIB_DIR%\org.json4s.json4s-ast_2.12-3.6.4.jar;%APP_LIB_DIR%\org.json4s.json4s-scalap_2.12-3.6.4.jar;%APP_LIB_DIR%\com.thoughtworks.paranamer.paranamer-2.8.jar;%APP_LIB_DIR%\com.typesafe.play.twirl-api_2.12-1.4.0.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-xml_2.12-1.1.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-server_2.12-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.play_2.12-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.build-link-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-exceptions-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-streams_2.12-2.7.0.jar;%APP_LIB_DIR%\org.reactivestreams.reactive-streams-1.0.2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-stream_2.12-2.5.19.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-actor_2.12-2.5.19.jar;%APP_LIB_DIR%\com.typesafe.config-1.3.3.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-java8-compat_2.12-0.9.0.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-protobuf_2.12-2.5.19.jar;%APP_LIB_DIR%\com.typesafe.ssl-config-core_2.12-0.3.7.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-parser-combinators_2.12-1.1.1.jar;%APP_LIB_DIR%\org.slf4j.jul-to-slf4j-1.7.25.jar;%APP_LIB_DIR%\org.slf4j.jcl-over-slf4j-1.7.25.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-slf4j_2.12-2.5.19.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-core-2.9.8.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-annotations-2.9.8.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-databind-2.9.8.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jdk8-2.9.8.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jsr310-2.9.8.jar;%APP_LIB_DIR%\com.typesafe.play.play-json_2.12-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-functional_2.12-2.7.0.jar;%APP_LIB_DIR%\org.typelevel.macro-compat_2.12-1.1.1.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-collection-compat_2.12-0.1.1.jar;%APP_LIB_DIR%\joda-time.joda-time-2.10.1.jar;%APP_LIB_DIR%\com.google.guava.guava-27.0-jre.jar;%APP_LIB_DIR%\com.google.guava.failureaccess-1.0.jar;%APP_LIB_DIR%\com.google.guava.listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_LIB_DIR%\com.google.code.findbugs.jsr305-3.0.2.jar;%APP_LIB_DIR%\org.checkerframework.checker-qual-2.5.2.jar;%APP_LIB_DIR%\com.google.errorprone.error_prone_annotations-2.2.0.jar;%APP_LIB_DIR%\org.codehaus.mojo.animal-sniffer-annotations-1.17.jar;%APP_LIB_DIR%\io.jsonwebtoken.jjwt-0.9.1.jar;%APP_LIB_DIR%\javax.xml.bind.jaxb-api-2.3.1.jar;%APP_LIB_DIR%\javax.activation.javax.activation-api-1.2.0.jar;%APP_LIB_DIR%\javax.transaction.jta-1.1.jar;%APP_LIB_DIR%\javax.inject.javax.inject-1.jar;%APP_LIB_DIR%\com.typesafe.play.play-logback_2.12-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-akka-http-server_2.12-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-core_2.12-10.1.7.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-parsing_2.12-10.1.7.jar;%APP_LIB_DIR%\com.typesafe.play.filters-helpers_2.12-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-ehcache_2.12-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-cache_2.12-2.7.0.jar;%APP_LIB_DIR%\net.sf.ehcache.ehcache-2.10.6.jar;%APP_LIB_DIR%\org.ehcache.jcache-1.0.1.jar;%APP_LIB_DIR%\javax.cache.cache-api-1.0.0.jar;%APP_LIB_DIR%\com.typesafe.slick.slick_2.12-3.3.0.jar;%APP_LIB_DIR%\com.typesafe.slick.slick-codegen_2.12-3.3.0.jar;%APP_LIB_DIR%\com.github.tminglei.slick-pg_2.12-0.17.2.jar;%APP_LIB_DIR%\com.github.tminglei.slick-pg_core_2.12-0.17.2.jar;%APP_LIB_DIR%\org.postgresql.postgresql-42.2.5.jar;%APP_LIB_DIR%\com.github.tminglei.slick-pg_joda-time_2.12-0.17.2.jar;%APP_LIB_DIR%\org.joda.joda-convert-2.1.2.jar;%APP_LIB_DIR%\com.typesafe.play.play-slick_2.12-4.0.0.jar;%APP_LIB_DIR%\com.typesafe.slick.slick-hikaricp_2.12-3.3.0.jar;%APP_LIB_DIR%\com.zaxxer.HikariCP-3.2.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-jdbc-api_2.12-2.7.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-slick-evolutions_2.12-4.0.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-jdbc-evolutions_2.12-2.7.0.jar;%APP_LIB_DIR%\com.github.t3hnar.scala-bcrypt_2.12-3.1.jar;%APP_LIB_DIR%\de.svenkubiak.jBCrypt-0.4.1.jar;%APP_LIB_DIR%\org.webjars.webjars-play_2.12-2.7.0.jar;%APP_LIB_DIR%\org.webjars.requirejs-2.3.6.jar;%APP_LIB_DIR%\org.webjars.webjars-locator-0.36.jar;%APP_LIB_DIR%\org.webjars.webjars-locator-core-0.37.jar;%APP_LIB_DIR%\org.apache.commons.commons-lang3-3.8.1.jar;%APP_LIB_DIR%\org.apache.commons.commons-compress-1.18.jar;%APP_LIB_DIR%\org.webjars.foundation-6.4.3.jar;%APP_LIB_DIR%\org.webjars.modernizr-2.8.3.jar;%APP_LIB_DIR%\org.webjars.fastclick-1.0.3.jar;%APP_LIB_DIR%\org.webjars.jQuery-Autocomplete-1.2.7.jar;%APP_LIB_DIR%\org.webjars.jquery-2.1.1.jar;%APP_LIB_DIR%\org.webjars.jquery-cookie-1.4.0.jar;%APP_LIB_DIR%\org.webjars.Placeholders.js-3.0.2.jar;%APP_LIB_DIR%\org.webjars.normalize.css-3.0.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-guice_2.12-2.7.0.jar;%APP_LIB_DIR%\com.google.inject.guice-4.2.2.jar;%APP_LIB_DIR%\aopalliance.aopalliance-1.0.jar;%APP_LIB_DIR%\com.google.inject.extensions.guice-assistedinject-4.2.2.jar;%APP_LIB_DIR%\com.github.pathikrit.better-files_2.12-3.7.0.jar;%APP_LIB_DIR%\com.github.tototoshi.scala-fixture_2.12-0.3.0.jar;%APP_LIB_DIR%\org.camunda.bpm.dmn.camunda-engine-dmn-7.10.0.jar;%APP_LIB_DIR%\org.camunda.commons.camunda-commons-utils-1.6.0.jar;%APP_LIB_DIR%\org.camunda.commons.camunda-commons-logging-1.6.0.jar;%APP_LIB_DIR%\org.camunda.commons.camunda-commons-typed-values-1.6.0.jar;%APP_LIB_DIR%\org.camunda.bpm.model.camunda-dmn-model-7.10.0.jar;%APP_LIB_DIR%\org.camunda.bpm.model.camunda-xml-model-7.10.0.jar;%APP_LIB_DIR%\org.camunda.bpm.dmn.camunda-engine-feel-api-7.10.0.jar;%APP_LIB_DIR%\org.camunda.bpm.dmn.camunda-engine-feel-juel-7.10.0.jar;%APP_LIB_DIR%\de.odysseus.juel.juel-api-2.2.7.jar;%APP_LIB_DIR%\de.odysseus.juel.juel-spi-2.2.7.jar;%APP_LIB_DIR%\de.odysseus.juel.juel-impl-2.2.7.jar;%APP_LIB_DIR%\ru.ns.playsm-0.1.2-assets.jar"
set "APP_MAIN_CLASS=play.core.server.ProdServerStart"
set "SCRIPT_CONF_FILE=%APP_HOME%\conf\application.ini"

rem if configuration files exist, prepend their contents to the script arguments so it can be processed by this runner
call :parse_config "%SCRIPT_CONF_FILE%" SCRIPT_CONF_ARGS

call :process_args %SCRIPT_CONF_ARGS% %%*

set _JAVA_OPTS=!_JAVA_OPTS! !_JAVA_PARAMS!

if defined CUSTOM_MAIN_CLASS (
    set MAIN_CLASS=!CUSTOM_MAIN_CLASS!
) else (
    set MAIN_CLASS=!APP_MAIN_CLASS!
)

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" !_JAVA_OPTS! !PLAYSM_OPTS! -cp "%APP_CLASSPATH%" %MAIN_CLASS% !_APP_ARGS!

@endlocal

exit /B %ERRORLEVEL%


rem Loads a configuration file full of default command line options for this script.
rem First argument is the path to the config file.
rem Second argument is the name of the environment variable to write to.
:parse_config
  set _PARSE_FILE=%~1
  set _PARSE_OUT=
  if exist "%_PARSE_FILE%" (
    FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%_PARSE_FILE%") DO (
      set _PARSE_OUT=!_PARSE_OUT! %%i
    )
  )
  set %2=!_PARSE_OUT!
exit /B 0


:add_java
  set _JAVA_PARAMS=!_JAVA_PARAMS! %*
exit /B 0


:add_app
  set _APP_ARGS=!_APP_ARGS! %*
exit /B 0


rem Processes incoming arguments and places them in appropriate global variables
:process_args
  :param_loop
  call set _PARAM1=%%1
  set "_TEST_PARAM=%~1"

  if ["!_PARAM1!"]==[""] goto param_afterloop


  rem ignore arguments that do not start with '-'
  if "%_TEST_PARAM:~0,1%"=="-" goto param_java_check
  set _APP_ARGS=!_APP_ARGS! !_PARAM1!
  shift
  goto param_loop

  :param_java_check
  if "!_TEST_PARAM:~0,2!"=="-J" (
    rem strip -J prefix
    set _JAVA_PARAMS=!_JAVA_PARAMS! !_TEST_PARAM:~2!
    shift
    goto param_loop
  )

  if "!_TEST_PARAM:~0,2!"=="-D" (
    rem test if this was double-quoted property "-Dprop=42"
    for /F "delims== tokens=1,*" %%G in ("!_TEST_PARAM!") DO (
      if not ["%%H"] == [""] (
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
      ) else if [%2] neq [] (
        rem it was a normal property: -Dprop=42 or -Drop="42"
        call set _PARAM1=%%1=%%2
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
        shift
      )
    )
  ) else (
    if "!_TEST_PARAM!"=="-main" (
      call set CUSTOM_MAIN_CLASS=%%2
      shift
    ) else (
      set _APP_ARGS=!_APP_ARGS! !_PARAM1!
    )
  )
  shift
  goto param_loop
  :param_afterloop

exit /B 0
