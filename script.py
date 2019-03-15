# This is simple python script just to remove duplicates, sort all wumpus solution in ascending order and enumerate them.
with open('pyinput.txt', 'r') as inp, open('pyoutput.txt', 'w') as out:
    input_line = inp.readline()
    if len(input_line) == 0:
        out.write("No Solutions")
    else:
        unsorted_moves = list(set(input_line.replace(',',' ').split(']')))
        moves_list = [solution.replace('[', '%#').replace('%', str(enum)).replace('#', ') ') for enum, solution  in enumerate(sorted(unsorted_moves[1:], key = len))]
        for ind, line in enumerate(moves_list):
            tmp = line.index('->')
            moves_list[ind] = '{}, Score = {}'.format(line[tmp+2:],line[:tmp])

        moves_separated_str = '\n'.join(moves_list)
        out.writelines(moves_separated_str)
