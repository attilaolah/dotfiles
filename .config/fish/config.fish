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
    abbr --add gd git diff
    abbr --add gp git push
    abbr --add gr git remote -v
    abbr --add gl git log --graph --abbrev-commit --pretty=\"format:(set_color -o -u brred)%h(set_color normal)(set_color yellow)%d(set_color normal) (set_color red)\(%cr\)(set_color normal) %s — (set_color blue)%ae(set_color normal)\"

    function gg
        git commit -m "$argv"
    end
end
