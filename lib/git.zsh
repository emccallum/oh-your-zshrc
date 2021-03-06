git_clone () {
  repo=$(head -n 1 $1)
  dest=$2
  if ! git clone --quiet $repo $dest; then
    fail "clone for $repo failed"
  fi

  success "cloned $repo to `basename $dest`"

  dir=$(dirname $1)
  base=$(basename ${1%.*})
  for patch in $(find $dir -maxdepth 2 -name $base\*.gitpatch); do
    pushd $dest >> /dev/null
    if ! git am --quiet $patch; then
      fail "apply patch failed"
    fi

    success "applied $patch"
    popd >> /dev/null
  done
}

function git_pull_repos() {
  for file in $(dotfiles_find \*.gitrepo); do
    repo="$HOME/.`basename \"${file%.*}\"`"
    git_pull $repo &
  done
  wait
}

function git_pull() {
  pushd $1 > /dev/null
  if ! git pull --rebase --quiet origin master; then
    fail "could not update $repo"
  fi
  success "updated $repo"
  popd >> /dev/null
}
