#!/bin/bash
# find_path_from_jar_file.sh - 修复版

set -e

if [ "$#" -ne 2 ]; then
    echo "用法: $0 <搜索路径> <查找的目录>"
    echo "示例: $0 com/apusic/license /opt/ApusicAS"
    exit 1
fi

SEARCH_PATH="$1"
BASE_DIR="$2"
MAX_PROCESSES=8

echo "🔍 搜索路径: $SEARCH_PATH"
echo "📁 搜索目录: $BASE_DIR"
echo "⚡ 使用最多 $MAX_PROCESSES 个并行进程"
echo "========================================"

# 获取JAR文件列表
echo "正在收集JAR文件..."
JAR_FILES=()
while IFS= read -r -d '' file; do
    JAR_FILES+=("$file")
done < <(find "$BASE_DIR" -name "*.jar" -type f -print0)

TOTAL=${#JAR_FILES[@]}
echo "找到 $TOTAL 个JAR文件"
echo "开始扫描..."
echo ""

# 创建临时目录用于结果
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 处理函数
process_jar() {
    local jar="$1"
    local jar_name="$(basename "$jar")"
    local output="$TEMP_DIR/${jar_name//[^a-zA-Z0-9]/_}.txt"
    
    # 检查JAR内容
    if jar tf "$jar" 2>/dev/null | grep -q "^$SEARCH_PATH"; then
        local count
        count=$(jar tf "$jar" 2>/dev/null | grep -c "^$SEARCH_PATH")
        
        # 写入临时文件
        {
            echo "=== JAR文件: $jar_name ==="
            echo "完整路径: $jar"
            echo "匹配数量: $count"
            
            # 显示匹配的前几个
            if [ "$count" -gt 0 ]; then
                echo "匹配内容:"
                jar tf "$jar" 2>/dev/null | \
                    grep "^$SEARCH_PATH" | \
                    head -5 | sed 's/^/  /'
            fi
            echo ""
        } > "$output"
    fi
}

export -f process_jar
export SEARCH_PATH TEMP_DIR

# 并行处理
printf "%s\0" "${JAR_FILES[@]}" | \
    xargs -0 -P "$MAX_PROCESSES" -I {} bash -c 'process_jar "$@"' _ {}

# 汇总结果
echo "========================================"
RESULTS=("$TEMP_DIR"/*.txt)
if [ ${#RESULTS[@]} -gt 0 ] && [ -f "${RESULTS[0]}" ]; then
    echo "✅ 找到以下匹配的JAR文件:"
    echo "========================================"
    cat "$TEMP_DIR"/*.txt
    
    echo "========================================"
    echo "📊 统计结果:"
    echo "总共扫描: $TOTAL 个JAR文件"
    echo "找到匹配: ${#RESULTS[@]} 个JAR文件"
else
    echo "❌ 没有找到包含路径 '$SEARCH_PATH' 的JAR文件"
fi