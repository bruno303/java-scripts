#!/bin/bash

set -e

## Replaceable vars
EXECUTION_MODULE="web"
MAIN_CLASS="com.bso.gradledemo.ApplicationKt"
JAVA_OPTS="-Dspring.profiles.active=local -Dspring.output.ansi.enabled=always"
DEBUG=0


## How to generate classpath for maven modules:
: '
tasks.register("writeClasspath") {
    doLast {
        val classpathFile = file(".bso/classpath.txt")
        file(".bso").mkdir()
        val classpathEntries = configurations.runtimeClasspath.get().files.map { it.absolutePath }
        classpathFile.writeText(classpathEntries.joinToString(File.pathSeparator))
    }
}
'


function replace() {
    local newText="$2"
    local text="$3"
    local pattern="$1.*\\.jar"

    IFS=':' read -ra parts <<< "$text"

    for i in "${!parts[@]}"; do
        # Check if the part contains "oldText" followed by any string and ends with ".jar"
        if [[ ${parts[$i]} =~ $pattern ]]; then
            parts[i]="${parts[$i]//${parts[$i]}/$newText}"
        fi
    done

    local new_text
    new_text=$(IFS=: ; echo "${parts[*]}")
    echo "$new_text"
}

## Internal vars
PROJECT_DIR=$(pwd)
LOCAL_CLASSES="$PROJECT_DIR/$EXECUTION_MODULE/build/classes/kotlin/main:$PROJECT_DIR/$EXECUTION_MODULE/build/resources/main"
CLASSPATH_FILE="$PROJECT_DIR/$EXECUTION_MODULE/.bso/classpath.txt"

CLASSPATH=$(cat "$CLASSPATH_FILE")

# Include build/classes/{java|kotlin|groovy} and build/resources/main
CLASSPATH=$(replace "gradle-demo/service" "$PROJECT_DIR/service/build/classes/kotlin/main:$PROJECT_DIR/service/build/resources/main" "$CLASSPATH")

FINAL_CLASSPATH="$CLASSPATH:$LOCAL_CLASSES"

#echo "$FINAL_CLASSPATH"

## Handle debug flag
if [ $DEBUG -gt 0 ]; then
    JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005"
fi

## Run application
java $JAVA_OPTS \
    -cp "$FINAL_CLASSPATH" \
    "$MAIN_CLASS"
