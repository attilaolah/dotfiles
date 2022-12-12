source ~/.profile

if status is-interactive
    ## Disable welcome
    set --universal fish_greeting

    ## Abbreviations:
    abbr --add o xdg-open

    abbr --add ... cd ../..
    abbr --add .... cd ../../..
    abbr --add ..... cd ../../../..
    abbr --add ...... cd ../../../../..

    abbr --add l ls -lh
    abbr --add ll ls -la

    abbr --add c curl -s --dump-header /dev/stderr

    abbr --add v nvim
    abbr --add nv nvim

    abbr --add g git status
    abbr --add ga git add -p .
    abbr --add gb git branch -avv
    abbr --add gc git commit -v
    abbr --add gl git log --abbrev-commit --decorate --graph --pretty=oneline
    abbr --add gp git push
    abbr --add gr git remote -v

    function gg
        git commit -m "$argv"
    end

    abbr --add h hg status
end

# Work stuff goes here.
if test -e  ~/.config/fish/google.fish
    source ~/.config/fish/google.fish
end
