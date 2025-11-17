param(
    [string]$m
)

$MDBOX_PATH = "E:\learn\mdbox"

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
& "$MDBOX_PATH\tool\build.bat"

# 输出开始推送信息
Write-Host "`n开始推送到远程仓库`n" -ForegroundColor DarkGreen

# 切换到备份仓库目录
Set-Location $MDBOX_PATH

# 获取当前时间格式
$now = Get-Date -Format 'yyyy.MMdd_HH:mm'

# 根据是否收到 -m 参数生成提交信息
if ($m) {
    $commitMsg = "Update[$m][$now]"
} else {
    $commitMsg = "Update[$now]"
}

# 执行 Git 操作
git add .
git commit -m "$commitMsg"
git push
