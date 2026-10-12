#!/usr/bin/bash

# update fcitx5-rime
# 尊重主仓库 gitlink pin 的提交：只有当它不在 fork 网络里（拉不到）时才回退到 fork 的 master。
# 之前无条件 checkout gh/master，导致 gitlink 形同虚设——子模块改了但没推 master 时
# CI 会静默用旧代码构建（2026-10-12 外部路径功能就因此没生效）。
echo "updating fcitx5-rime"
pushd plugin/rime/src/main/cpp/fcitx5-rime
PINNED=$(git rev-parse HEAD)
git remote add gh https://github.com/SandyYuR/fcitx5-rime.git || git remote set-url gh https://github.com/SandyYuR/fcitx5-rime.git
if git fetch -v gh "$PINNED" 2>/dev/null && git checkout "$PINNED" 2>/dev/null; then
  echo "fcitx5-rime: using gitlink-pinned $PINNED"
else
  echo "fcitx5-rime: pinned $PINNED not in fork network, falling back to gh/master"
  git fetch -v gh master
  git checkout gh/master
fi
popd
sed -i 's|github.com/fcitx/|github.com/SandyYuR/|g; s|github.com/fxliang/|github.com/SandyYuR/|g' app/licenses/libraries/fcitx5-rime.json

# apply fcitx5 patch from fcitx5-rime
echo "applying fcitx5 patch"
pushd lib/fcitx5/src/main/cpp/fcitx5
# reset to clean state first
git checkout -- .
git apply ../../../../../../plugin/rime/src/main/cpp/fcitx5-rime/fcitx5-alt-trigger-v4point1.patch || echo "fcitx5 patch already applied or failed"
popd

# update prebuilt
echo "updating prebuilt"
pushd lib/fcitx5/src/main/cpp/prebuilt
git remote add gh https://github.com/SandyYuR/prebuilt.git || git remote set-url gh https://github.com/SandyYuR/prebuilt.git
git fetch -v gh master
git checkout gh/master
popd
