#!/bin/bash
# ============================================
# 王东杰个人品牌官网 — 一键部署脚本
# 用法：
#   第一次部署： bash deploy.sh
#   后续更新：   bash deploy.sh
# ============================================

set -e

SITE_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "📦 站点目录：$SITE_DIR"

# 1. 检查 gh 是否已登录
if ! gh auth status &>/dev/null; then
  echo ""
  echo "🔑 请先登录 GitHub："
  echo "   gh auth login"
  echo ""
  echo "   或者直接使用 Personal Access Token："
  echo "   export GH_TOKEN=你的token"
  echo ""
  exit 1
fi

# 2. 获取 GitHub 用户名
GH_USER=$(gh api user --jq '.login')
echo "👤 GitHub 用户：$GH_USER"

# 3. 创建远程仓库（如果不存在）
REPO_EXISTS=$(gh repo view "$GH_USER/wangdongjie-cfo" --json name 2>/dev/null || echo "NOT_FOUND")
if [ "$REPO_EXISTS" = "NOT_FOUND" ]; then
  echo "📦 创建远程仓库 wangdongjie-cfo ..."
  gh repo create wangdongjie-cfo --public --description "王东杰 | Wang Dongjie — CFO个人品牌官网" --homepage "https://$GH_USER.github.io/wangdongjie-cfo/"
  git remote add origin "https://github.com/$GH_USER/wangdongjie-cfo.git"
else
  echo "✅ 远程仓库已存在"
  git remote set-url origin "https://github.com/$GH_USER/wangdongjie-cfo.git"
fi

# 4. 推送到 GitHub
echo "🚀 推送到 GitHub..."
git push -u origin main

# 5. 启用 GitHub Pages
echo "🌐 启用 GitHub Pages..."
gh api "repos/$GH_USER/wangdongjie-cfo/pages" \
  --method POST \
  --field source='{"branch":"main","path":"/"}' 2>/dev/null || \
  gh api "repos/$GH_USER/wangdongjie-cfo/pages" \
    --method PUT \
    --field source='{"branch":"main","path":"/"}' 2>/dev/null

echo ""
echo "✅ 部署完成！"
echo "   网站地址：https://$GH_USER.github.io/wangdongjie-cfo/"
echo "   主页：     https://$GH_USER.github.io/wangdongjie-cfo/"
echo "   英文版：   https://$GH_USER.github.io/wangdongjie-cfo/en/"
echo ""
echo "📋 下一步："
echo "   1. 购买域名 wangdongjie.com → 在仓库 Settings > Pages 中绑定"
echo "   2. 提交 sitemap.xml 到百度站长平台"
echo "   3. 提交 sitemap.xml 到 Google Search Console"
