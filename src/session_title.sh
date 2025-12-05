BASE_DIRS=(
  /apps/home/${USER}/workspace/spde-apps/
  /apps/home/${USER}/workspace/us-power/
)

title="Devbox"
for BASE_DIR in "${BASE_DIRS[@]}"; do
  if [[ $PWD == "$BASE_DIR"* ]]; then
    relpath=${PWD:${#BASE_DIR}};
    app_name=${relpath%%/*};
    title=${app_name^^}
    break
  fi
done

printf "\033]0;${title} - $(hostname)\007"
