# Sourced from ~/.bashrc and ~/.zshrc. META_REPO_DOTFILES is a colon-separated
# list of the dotfiles mounted from meta-repo.local.yaml; source each file.
# Plain POSIX string handling so it behaves the same in bash and zsh.
_mr_rest=${META_REPO_DOTFILES:-}
while [ -n "$_mr_rest" ]; do
    _mr_file=${_mr_rest%%:*}
    case $_mr_rest in
        *:*) _mr_rest=${_mr_rest#*:} ;;
        *) _mr_rest= ;;
    esac
    [ -f "$_mr_file" ] && . "$_mr_file"
done
unset _mr_rest _mr_file
