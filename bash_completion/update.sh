#!/usr/bin/env bash
COMPLETIONS=$XDG_CONFIG_DIR/bash-completion/completions/

# ---- Update Completions ----
echo "Updating Completions..."

# :gh-cli
if command -v gh &> /dev/null; then
    echo -n "gh-cli..."
    gh completion -s bash > $COMPLETIONS/gh
    echo "done."
fi

# :kubectl
# https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/
if command -v kubectl &> /dev/null; then
    echo -n "kubect..."
    kubectl completion bash > $COMPLETIONS/kubectl
    echo "done."
fi

# :docker
# https://gist.github.com/toschneck/2df90c66e0f8d4c6567d69a36bfc5bcd
echo -n "docker..."
curl -L https://raw.githubusercontent.com/docker/cli/v$(docker version --format '{{.Server.Version}}')/contrib/completion/bash/docker -o $COMPLETIONS/docker
echo "done."

# :docker-compose
# https://gist.github.com/toschneck/2df90c66e0f8d4c6567d69a36bfc5bcd
echo -n "docker-compose..."
curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose -o $COMPLETIONS/docker-compose
echo "done."

