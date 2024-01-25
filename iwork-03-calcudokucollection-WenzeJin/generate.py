result_root = "./result/"

difficulty = ['beginner', 'easy', 'medium', 'hard', 'mixed', 'no-op']

dict_difficulty = {
    'beginner': 'KX',
    'easy': 'E',
    'medium': 'M',
    'hard': 'H',
    'mixed': 'X',
    'no-op': 'NOP'
}

volumn_max = 20

book_max = 50

def generate_url(size:int, volume:int, book:int, difficulty:str) -> str:
    """_summary_

    Args:
        volume (int): volume number
        book (int): book number
        difficulty (str): difficulty

    Returns:
        str: url to the puzzle
    """
    
    if volume == 1:
        return 'https://files.krazydad.com/inkies/sfiles/INKY_' + str(size) + dict_difficulty[difficulty] + '_b{:0>3d}_4pp.pdf'.format(book)
    else:
        return 'https://files.krazydad.com/inkies/sfiles/INKY_v' + str(volume) + '_' + str(size) + dict_difficulty[difficulty] + '_b{:0>3d}_4pp.pdf'.format(book)
    

if __name__ == '__main__':
    for size in range(4, 7):
        for diff in difficulty:
            for volume in range(1, volumn_max + 1):
                with open(result_root + str(size) + '_' + diff + '_' + str(volume) + '.txt', 'w') as f:
                    for book in range(1, book_max + 1):
                        url = generate_url(size, volume, book, diff)
                        f.write(url + '\n')
                    f.close()
                    
