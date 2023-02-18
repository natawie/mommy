# Configurable
[ -z "$mommy" ] && mommy="../../main/sh/mommy"

# Constants
config="./config"
n="
"


Describe "mommy"
    clean_config() { rm -f "$config"; }
    Before "clean_config"
    After "clean_config"

    Describe "command-line options"
        Describe "help information"
            It "outputs help information using -h"
                When run "$mommy" -h
                The word 1 of output should equal "mommy(1)"
                The status should be success
            End

            It "outputs help information using --help"
                When run "$mommy" --help
                The word 1 of output should equal "mommy(1)"
                The status should be success
            End

            It "outputs help information even when -h is not the first option"
                When run "$mommy" -c "./a_file" -h
                The word 1 of output should equal "mommy(1)"
                The status should be success
            End
        End

        Describe "custom configuration file"
            It "ignores an invalid path"
                When run "$mommy" -c "./does_not_exist" true
                The error should not equal ""
                The status should be success
            End

            It "uses the configuration from the given file"
                echo "MOMMY_COMPLIMENTS='apply news';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal "apply news"
                The status should be success
            End
        End

        Describe "command"
            It "writes a compliment to stderr if the command returns 0 status"
                echo "MOMMY_COMPLIMENTS='purpose wall';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal "purpose wall"
                The status should be success
            End

            It "writes an encouragement to stderr if the command returns non-0 status"
                echo "MOMMY_ENCOURAGEMENTS='razor woolen';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" false
                The error should equal "razor woolen"
                The status should be failure
            End

            It "returns the non-0 status of the command"
                When run "$mommy" exit 4
                The error should not equal ""
                The status should equal 4
            End

            It "passes all arguments to the command"
                echo "MOMMY_COMPLIMENTS='disagree mean';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" echo a b c
                The output should equal "a b c"
                The error should equal "disagree mean"
                The status should be success
            End
        End

        Describe "eval"
            It "writes a compliment to stderr if the evaluated command returns 0 status"
                echo "MOMMY_COMPLIMENTS='bold accord';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "true"
                The error should equal "bold accord"
                The status should be success
            End

            It "writes an encouragement to stderr if the evaluated command returns non-0 status"
                echo "MOMMY_ENCOURAGEMENTS='head log';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "false"
                The error should equal "head log"
                The status should be failure
            End

            It "returns the non-0 status of the evaluated command"
                When run "$mommy" -e "exit 4"
                The error should not equal ""
                The status should equal 4
            End

            It "passes all arguments to the command"
                echo "MOMMY_COMPLIMENTS='desire bread';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "echo a b c"
                The output should equal "a b c"
                The error should equal "desire bread"
                The status should be success
            End

            It "considers the command a success if all parts succeed"
                echo "MOMMY_COMPLIMENTS='milk literary';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "echo 'a/b/c' | cut -d '/' -f 1"
                The output should be present
                The error should equal "milk literary"
                The status should be success
            End

            It "considers the command a failure if any part fails"
                echo "MOMMY_ENCOURAGEMENTS='bear cupboard';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -e "echo 'a/b/c' | cut -d '/' -f 0"
                The error should be present
                The status should be failure
            End
        End

        Describe "status"
            It "writes a compliment to stderr if the status is 0"
                echo "MOMMY_COMPLIMENTS='station top';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -s 0
                The error should equal "station top"
                The status should be success
            End

            It "writes an encouragement to stderr if the status is non-0"
                echo "MOMMY_ENCOURAGEMENTS='mend journey';MOMMY_SUFFIX=''" > "$config"

                When run "$mommy" -c "$config" -s 1
                The error should equal "mend journey"
                The status should be failure
            End

            It "returns the given non-0 status"
                When run "$mommy" -s 167
                The error should not equal ""
                The status should equal 167
            End
        End
    End

    Describe "configuration"
        Describe "template variables"
            It "replaces %%SWEETIE%%"
                echo "MOMMY_COMPLIMENTS='>%%SWEETIE%%<';MOMMY_SUFFIX='';MOMMY_SWEETIE='attempt'" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal ">attempt<"
                The status should be success
            End

            It "replaces %%THEIR%%"
                echo "MOMMY_COMPLIMENTS='>%%THEIR%%<';MOMMY_SUFFIX='';MOMMY_THEIR='respect'" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal ">respect<"
                The status should be success
            End

            It "replaces %%CAREGIVER%%"
                echo "MOMMY_COMPLIMENTS='>%%CAREGIVER%%<';MOMMY_SUFFIX='';MOMMY_CAREGIVER='help'" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal ">help<"
                The status should be success
            End

            It "appends the suffix"
                echo "MOMMY_COMPLIMENTS='>';MOMMY_SUFFIX='respect'" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal ">respect"
                The status should be success
            End

            It "chooses a random pronoun"
                # Runs mommy several times and checks if output is different at least once.
                # Probability of 1/(26^4)=1/456976 to fail even if code is correct.

                pronouns="a/b/c/d/e/f/g/h/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"
                echo "MOMMY_COMPLIMENTS='>%%THEIR%%<';MOMMY_SUFFIX='';MOMMY_THEIR='$pronouns'" > "$config"

                output1=$("$mommy" -c "$config" true 2>&1)
                output2=$("$mommy" -c "$config" true 2>&1)
                output3=$("$mommy" -c "$config" true 2>&1)
                output4=$("$mommy" -c "$config" true 2>&1)
                output5=$("$mommy" -c "$config" true 2>&1)

                [ "$output1" != "$output2" ] || [ "$output1" != "$output3" ] \
                                             || [ "$output1" != "$output4" ] \
                                             || [ "$output1" != "$output5" ]
                is_different="$?"

                When call test "$is_different" -eq 0
                The status should be success
            End

            It "chooses the empty string if no pronouns are set"
                echo "MOMMY_COMPLIMENTS='>%%THEIR%%<';MOMMY_SUFFIX='';MOMMY_THEIR=''" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal "><"
                The status should be success
            End
        End

        Describe "capitalization"
            It "changes the first character to lowercase if configured to 0"
                echo "MOMMY_COMPLIMENTS='Alive station';MOMMY_SUFFIX='';MOMMY_CAPITALIZE='0'" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal "alive station"
                The status should be success
            End

            It "changes the first character to uppercase if configured to 1"
                echo "MOMMY_COMPLIMENTS='inquiry speech';MOMMY_SUFFIX='';MOMMY_CAPITALIZE='1'" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal "Inquiry speech"
                The status should be success
            End

            It "uses the template's original capitalization if configured to the empty string"
                echo "MOMMY_COMPLIMENTS='Medicine frighten';MOMMY_SUFFIX='';MOMMY_CAPITALIZE=" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal "Medicine frighten"
                The status should be success
            End

            It "uses the template's original capitalization if configured to anything else"
                echo "MOMMY_COMPLIMENTS='Belong shore';MOMMY_SUFFIX='';MOMMY_CAPITALIZE='2'" > "$config"

                When run "$mommy" -c "$config" true
                The error should equal "Belong shore"
                The status should be success
            End
        End

        Describe "compliments/encouragements"
            Describe "selection sources"
                It "chooses from 'MOMMY_COMPLIMENTS'"
                    echo "MOMMY_COMPLIMENTS='spill drown';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "spill drown"
                    The status should be success
                End

                It "chooses from 'MOMMY_COMPLIMENTS_EXTRA'"
                    echo "MOMMY_COMPLIMENTS='';MOMMY_COMPLIMENTS_EXTRA='bill lump';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "bill lump"
                    The status should be success
                End

                It "outputs nothing if no compliments are set"
                    echo "MOMMY_COMPLIMENTS='';MOMMY_COMPLIMENTS_EXTRA='';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal ""
                    The status should be success
                End
            End

            Describe "separators"
                It "inserts a separator between 'MOMMY_COMPLIMENTS' and 'MOMMY_COMPLIMENTS_EXTRA'"
                    echo "MOMMY_COMPLIMENTS='curse';MOMMY_COMPLIMENTS_EXTRA='dear';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should not equal "curse dear"
                    The status should be success
                End

                It "uses / as a separator"
                    echo "MOMMY_COMPLIMENTS='boy/only';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should not equal "boy/only"
                    The status should be success
                End

                It "uses a newline as a separator"
                    echo "MOMMY_COMPLIMENTS='salt${n}staff';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should not equal "salt${n}staff"
                    The status should be success
                End

                It "removes entries containing only whitespace"
                    # Probability of ~1/30 to pass even if code is buggy

                    echo "MOMMY_COMPLIMENTS='  /  /wage rot/  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  ';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "wage rot"
                    The status should be success
                End
            End

            Describe "comments"
                It "ignores lines starting with '#'"
                    echo "MOMMY_COMPLIMENTS='weaken${n}#egg';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "weaken"
                    The status should be success
                End

                It "does not ignore lines starting with ' #'"
                    echo "MOMMY_COMPLIMENTS=' #seat';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal " #seat"
                    The status should be success
                End

                It "does not ignore lines with a '#' not at the start"
                    echo "MOMMY_COMPLIMENTS='lo#ud';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "lo#ud"
                    The status should be success
                End

                It "ignores the '/' in a comment line"
                    echo "MOMMY_COMPLIMENTS='figure${n}#penny/some';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "figure"
                    The status should be success
                End
            End

            Describe "whitespace in entries"
                It "retains leading whitespace in an entry"
                    echo "MOMMY_COMPLIMENTS=' rake fix';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal " rake fix"
                    The status should be success
                End

                It "retains trailing whitespace in an entry"
                    echo "MOMMY_COMPLIMENTS='read wealth ';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "read wealth "
                    The status should be success
                End
            End

            Describe "toggling"
                It "outputs nothing if a command succeeds but compliments are disabled"
                    echo "MOMMY_COMPLIMENTS_ENABLED='0';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal ""
                    The status should be success
                End

                It "outputs nothing if a command fails but encouragements are disabled"
                    echo "MOMMY_ENCOURAGEMENTS_ENABLED='0';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" false
                    The error should equal ""
                    The status should be failure
                End
            End

            Describe "forbidden words"
                It "does not output a compliment containing the forbidden word"
                    echo "MOMMY_COMPLIMENTS='mother search/fierce along';MOMMY_FORBIDDEN_WORDS='search';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "fierce along"
                    The status should be success
                End

                It "does not output a compliment containing at least one of the forbidden words"
                    echo "MOMMY_COMPLIMENTS='after boundary/failure school/instant delay';MOMMY_FORBIDDEN_WORDS='instant/boundary';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "failure school"
                    The status should be success
                End

                It "does not output compliments containing a forbidden phrase"
                    echo "MOMMY_COMPLIMENTS='member rid letter/rid wish over growth/member letter improve';MOMMY_FORBIDDEN_WORDS='member letter/wish over';MOMMY_SUFFIX=''" > "$config"

                    When run "$mommy" -c "$config" true
                    The error should equal "member rid letter"
                    The status should be success
                End
            End
        End
    End
End
