#!/bin/bash

# 批量反编译java jar包
# 脚本使用cfr 反编译工具
# 需要先安装cfr工具
# 安装方法：下载cfr jar包到本地目录，例如/usr/local/bin/cfr.jar
# 使用方法：bash decompile_jar.sh /path/to/jar/files /path/to/output/dir    
# 脚本会将指定目录下的所有jar包反编译到输出目录中，保持原有目录结构

# 检查参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 /path/to/jar/files /path/to/output/dir"
    exit 1
fi

JAR_DIR="$1"
OUTPUT_DIR="$2"
#CFR_JAR="/usr/local/bin/cfr.jar"
CFR_JAR="/usr/bin/cfr"  # 请根据实际情况修改cfr jar包路径
LOG_FILE="decompile_jar.log"
ERROR_LOG_FILE="decompile_jar_error.log"
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "Decompilation started at $START_TIME" | tee -a "$LOG_FILE"

# 检查cfr工具是否存在
if [ ! -f "$CFR_JAR" ]; then
    echo "CFR tool not found at $CFR_JAR" | tee -a "$ERROR_LOG_FILE"
    exit 1
fi

# 检查输出目录是否存在，不存在则创建
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to create output directory $OUTPUT_DIR" | tee -a "$ERROR_LOG_FILE"
        exit 1
    fi
fi

# 遍历jar目录下的所有jar包
find "$JAR_DIR" -type f -name "*.jar" | while read -r JAR_FILE; do
    RELATIVE_PATH="${JAR_FILE#$JAR_DIR/}"
    OUTPUT_SUBDIR="$OUTPUT_DIR/$(dirname "$RELATIVE_PATH")"
    mkdir -p "$OUTPUT_SUBDIR"
    if [ $? -ne 0 ]; then
        echo "Failed to create output subdirectory $OUTPUT_SUBDIR" | tee -a "$ERROR_LOG_FILE"
        continue
    fi
    echo "Decompiling $JAR_FILE to $OUTPUT_SUBDIR" | tee -a "$LOG_FILE"
    #java -jar "$CFR_JAR" --outputdir "$OUTPUT_SUBDIR" "$JAR_FILE" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
    "$CFR_JAR" --outputdir "$OUTPUT_SUBDIR" "$JAR_FILE" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "Failed to decompile $JAR_FILE" | tee -a "$ERROR_LOG_FILE"
    else
        echo "Successfully decompiled $JAR_FILE" | tee -a "$LOG_FILE"
    fi
done

END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "Decompilation ended at $END_TIME" | tee -a "$LOG_FILE"
echo "Decompilation process completed." | tee -a "$LOG_FILE"
exit 0
