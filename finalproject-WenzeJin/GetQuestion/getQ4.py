import argparse
import requests
import fitz
import cv2 as cv
from cnocr import CnOcr
import collections as std
import json

class UFSet:
    def hashPos(i:int, j:int, row_size:int):
        return row_size * i + j

    def __init__(self, size:int):
        self._parent= [-1] * size

    def __str__(self):
        return "UFSet(" + str(self._parent) + ")"

    def find(self, p:int) -> int:
        while self._parent[p] >= 0:
            p = self._parent[p]
        return p

    def union(self, p1:int, p2:int) -> None:
        f1 = self.find(p1)
        f2 = self.find(p2)
        if f1 == f2:
            return
        else:
            if -self._parent[f1] > -self._parent[f2]:
                bigger = f1
                smaller = f2
            else:
                bigger = f2
                smaller = f1
        self._parent[bigger] += self._parent[smaller]
        self._parent[smaller] = bigger


class GameRule:
    def __init__(self):
        self.op = ""
        self.target = 0
        self.blocks = []

    def __str__(self):
        return "GameRule(target:" + str(self.target) + ", op:" + str(self.op) + ", blocks:" + str(self.blocks) + ")"

    def addBlock(self, x:int, y:int):
        temp = [x, y]
        if temp not in self.blocks:
            self.blocks.append(temp)

class GameRules:
    def __init__(self):
        self.rules = []

    def getDict(self) -> dict:
        return {"rules": [each.__dict__ for each in self.rules]}

    def __str__(self) -> str:
        ir = ""
        for each in self.rules:
            ir += str(each)
        return "GameRules(" + ir + ")"

    def addRule(self, rule:GameRule) -> None:
        self.rules.append(rule)

    def defineTBD(self) -> None:
        for each in self.rules:
            if each.op == 'tbd': # To be defined
                if len(each.blocks) > 1:
                    each.op = '-'
                else:
                    each.op = 'imm' # immediate number


def isNumber(x:str) -> bool:
    try:
        int(x)
        return True
    except:
        return False

def isOperator(x:str) -> bool:
    if x == '+' or x == '-' or x == 'X' or x == '/' or x == 'x' or x == '×':
        return True
    return False

NAME = 'INKY_4M_b001_4pp'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--in_url', type=str,
                        default='https://files.krazydad.com/inkies/sfiles/' + NAME + '.pdf',
                        help = 'Input original pdf file from url')
    parser.add_argument('--dump_name', type=str,
                        default=NAME + '.pdf',
                        help = 'Set dumped file name')
    parser.add_argument('--out', type=str,
                        default='res/' + NAME + '.json',
                        help = 'Set output file')
    parser.add_argument('--img', type=str,
                        default='res/' + NAME + '.jpg',
                        help = 'Set output image.')
    args = parser.parse_args()

    with open(args.out, 'w') as jsonf:
        url = args.in_url
        raw = requests.get(args.in_url)
        with open('data/' + args.dump_name, 'wb') as target:
            target.write(raw.content)
        pdf_file = fitz.open('data/' + args.dump_name)
        pdf_reader = pdf_file.load_page(0)
        img_page = pdf_reader.get_pixmap()
        img_page.save('cache/img_page.png')
        page_data = cv.imread('cache/img_page.png', cv.IMREAD_GRAYSCALE)
        img_data = page_data[151:151+218, 51:51+218]
        tmp_img = cv.cvtColor(img_data, cv.COLOR_GRAY2BGR)      #颜色空间转换
        cv.imwrite('cache/img_ori.png', img_data)
        cv.imwrite(args.img, img_data)
        BLOCK_SIZE = 218 // 4
        tags = []
        for i in range(4):
            for j in range(4):
                img_blc = img_data[i*BLOCK_SIZE:(i+1)*BLOCK_SIZE, j*BLOCK_SIZE:(j+1)*BLOCK_SIZE]
                tmp_blc = cv.cvtColor(img_blc, cv.COLOR_GRAY2BGR)
                cv.imwrite('cache/img_blc.png', tmp_blc)
                ocr = CnOcr()
                res = ocr.ocr('cache/img_blc.png')
                buff = []
                if len(res) != 0:
                    buff.append(i)
                    buff.append(j)
                    for content in res:
                        buff.append(content['text'])
                    if len(res) < 2:
                        buff.append('tbd')
                    while not isNumber(buff[2][-1]):
                        tmp = buff[2][-1]
                        buff[2] = buff[2][0:-1]
                        if isOperator(tmp):
                            buff[3] = tmp
                    if buff[-1] == '1':
                        buff[-1] = '/'
                    if buff[-1] == '×':
                        buff[-1] = 'X'
                    tags.append(buff)
        print(tags)
        img_data = cv.dilate(img_data, None, iterations=1)
        img_data = cv.erode(img_data, None, iterations=1)
        assert img_data is not None, "some thing wrong"
        img_edge = cv.Canny(img_data,50, 500, 5, L2gradient=True)

        cv.imwrite('cache/img_edge.png', img_edge)

        colored_map = [[0 for _ in range(4)] for _ in range(4)]
        curr_color = 1

        # We will bfs through the img_edge and color the map
        h, w = 218, 218
        step = 218 // 4
        point = start = [step // 2, step // 2]
        bias = [[1, 0], [0, 1], [-1, 0], [0, -1]]
        uf_set = UFSet(4 * 4)

        for i in range(4):
            for j in range(4):
                point = [start[0] + step * i, start[1] + step * j]
                for k in range(4):
                    block_flag = False
                    if i + bias[k][0] < 0 or i + bias[k][0] >= 4 or j + bias[k][1] < 0 or j + bias[k][1] >= 4:
                        continue
                    for pixel in range(step):
                        if img_edge[point[0] + pixel * bias[k][0]][point[1] + pixel * bias[k][1]] != 0:
                            block_flag = True
                            break
                        else:
                            block_flag = False
                    if not block_flag:
                        uf_set.union(4 * i + j, 4 * (i + bias[k][0]) + j + bias[k][1])

        print(uf_set)

        # use UFSet and bfs to color the map
        for i in range(4):
            for j in range(4):
                if colored_map[i][j] != 0:
                    # colored
                    continue
                q = std.deque()
                q.extend([[i, j]])
                while len(q):
                    ci, cj = q.popleft()
                    colored_map[ci][cj] = curr_color
                    for k in range(4):
                        if ci + bias[k][0] < 0 or ci + bias[k][0] >= 4 or cj + bias[k][1] < 0 or cj + bias[k][1] >= 4:
                            continue
                        if colored_map[ci + bias[k][0]][cj + bias[k][1]]:
                            continue
                        if uf_set.find(UFSet.hashPos(ci, cj, 4)) \
                                == uf_set.find(UFSet.hashPos(ci + bias[k][0], cj + bias[k][1], 4)):
                            q.extend([[ci + bias[k][0], cj + bias[k][1]]])
                curr_color += 1

        print(colored_map)

        visited = [[False for _ in range(4)] for _ in range(4)]

        rules = GameRules()

        # We will bfs from each tag cell and use the colored_map to creat the rules
        for tag in tags:
            rule = GameRule()
            si, sj = tag[0], tag[1]
            rule.target = int(tag[2])
            rule.op = tag[3]
            curr_color = colored_map[si][sj]
            q = std.deque()
            q.extend([[si, sj]])
            while len(q):
                ci, cj = q.popleft()
                visited[ci][cj] = True
                rule.addBlock(ci, cj)
                for k in range(4):
                    if ci + bias[k][0] < 0 or ci + bias[k][0] >= 4 or cj + bias[k][1] < 0 or cj + bias[k][1] >= 4:
                        continue
                    if visited[ci + bias[k][0]][cj + bias[k][1]]:
                        continue
                    if colored_map[ci + bias[k][0]][cj + bias[k][1]] == curr_color:
                        q.extend([[ci + bias[k][0], cj + bias[k][1]]])
            rules.addRule(rule)

        for i in range(4):
            for j in range(4):
                if not visited[i][j]:
                    tag = [i, j, '1', '-']
                    rule = GameRule()
                    si, sj = tag[0], tag[1]
                    rule.target = int(tag[2])
                    rule.op = tag[3]
                    curr_color = colored_map[si][sj]
                    q = std.deque()
                    q.extend([[si, sj]])
                    while len(q):
                        ci, cj = q.popleft()
                        visited[ci][cj] = True
                        rule.addBlock(ci, cj)
                        for k in range(4):
                            if ci + bias[k][0] < 0 or ci + bias[k][0] >= 4 or cj + bias[k][1] < 0 or cj + bias[k][
                                1] >= 4:
                                continue
                            if visited[ci + bias[k][0]][cj + bias[k][1]]:
                                continue
                            if colored_map[ci + bias[k][0]][cj + bias[k][1]] == curr_color:
                                q.extend([[ci + bias[k][0], cj + bias[k][1]]])
                    rules.addRule(rule)


        # We will store all the rules to a class and dump it to json
        rules.defineTBD()

        json_data = json.dumps(rules.getDict())

        print(json_data)

        json.dump(rules.getDict(), jsonf, indent=4)