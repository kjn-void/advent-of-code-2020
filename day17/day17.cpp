// compile with: g++ -O2 -march=native -flto -fopenmp -o day17 day17.cpp

#include <chrono>
#include <fstream>
#include <functional>
#include <iostream>
#include <numeric>
#include <tuple>
#include <unordered_set>
#include <vector>

typedef std::tuple<int, int> range;

class Pos4D {
    int x, y, z, w;
public:
    Pos4D(int _x, int _y, int _z = 0, int _w = 0) : x(_x), y(_y), z(_z), w(_w) { }

    std::vector<Pos4D> neighborsGet(bool fourDim = true) const {
        std::vector<Pos4D> neigh;

	for (int dw = -1; dw <= 1; dw++) {
	    for (int dz = -1; dz <= 1; dz++) {
		for (int dy = -1; dy <= 1; dy++) {
		    for (int dx = -1; dx <= 1; dx++) {
			if (dx != 0 || dy != 0 || dz != 0 || dw != 0) {
			    neigh.push_back(Pos4D(x + dx, y + dy, z + dz, w + dw));
			}
		    }
		}
	    }
	}
	return neigh;
    }

    bool operator==(const Pos4D &rhs) const {
	return x == rhs.x && y == rhs.y && z == rhs.z && w == rhs.w;
    }

    friend class std::hash<Pos4D>;
};

namespace std {
    template<>
    struct hash<Pos4D> {
	size_t operator()(const Pos4D &pos) const {
	    return pos.x ^ (pos.y << 3) ^ (pos.z << 6) ^ (pos.w << 9);
	}
    };
}

struct SetReducer {
    SetReducer(std::unordered_set<Pos4D> _set = {}) : set(_set) {}

    SetReducer& operator+= (const SetReducer &rhs) {
        set.insert(rhs.set.begin(), rhs.set.end());
        return *this;
    }

    std::unordered_set<Pos4D> set;
};

#pragma omp declare reduction(SetReducerInsert: SetReducer: omp_out += omp_in)

class World {
    std::unordered_set<Pos4D> activeCubes;
    range xLim;
    range yLim;
    range zLim = range(0, 0);
    range wLim = range(0, 0);
    bool haveFourDim = false;

public:
    World(const std::vector<std::string> &initialState, bool useForthDim = false) {
        xLim = range(0, initialState.front().size());
	yLim = range(0, initialState.size());
        haveFourDim = useForthDim;

	for (int y = 0; y < initialState.size(); y++) {
	    const auto &line = initialState[y];
	    for (int x = 0; x < line.size(); x++) {
		const auto repr = line[x];
		if (repr == '#') {
		    activeCubes.insert(Pos4D(x, y));
		}
	    }
	}
    }

    int neighborCount(const Pos4D &center) const {
	const auto neighbors = center.neighborsGet();
	return std::accumulate(neighbors.begin(),
			       neighbors.end(),
			       0,
			       [this](int cnt, const Pos4D &pos) {
				   return cnt + (activeCubes.count(pos) > 0 ? 1 : 0);
			       });
    }

    void boundaryExtend(range &bound) const {
	std::get<0>(bound)--;
	std::get<1>(bound)++;
    }

    void nextCycle() {
	SetReducer nextActiveCubes;

	boundaryExtend(xLim);
        boundaryExtend(yLim);
        boundaryExtend(zLim);
        if (haveFourDim) {
            boundaryExtend(wLim);
        }

#pragma omp parallel for reduction(SetReducerInsert: nextActiveCubes)
        for (int x = std::get<0>(xLim); x <= std::get<1>(xLim); x++) {
            for (int w = std::get<0>(wLim); w <= std::get<1>(wLim); w++) {
                for (int z = std::get<0>(zLim); z <= std::get<1>(zLim); z++) {
                    for (int y = std::get<0>(yLim); y <= std::get<1>(yLim); y++) {
			Pos4D pos(x, y, z, w);
                        auto neighCnt = neighborCount(pos);
                        if (neighCnt == 3 || (neighCnt == 2 && activeCubes.count(pos) > 0)) {
                            nextActiveCubes.set.insert(pos);
                        }
                    }
                }
            }
        }

        activeCubes = nextActiveCubes.set;
    }

    int activeCubesGet() {
	return activeCubes.size();
    }
};

void bench(std::function<void()> fn) {
    auto start = std::chrono::steady_clock::now();
    fn();
    auto finish = std::chrono::steady_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(finish - start);
    std::cout << "Took : " << duration.count() << "ms\n";
}

int main() {
    std::vector<std::string> input;
    std::fstream fin("input.txt");
    std::string line;
    while (std::getline(fin, line)) {
	input.push_back(line);
    }

    bench([&input]() {
	World world(input);
	for (int cycle = 1; cycle <= 6; cycle++) {
	    world.nextCycle();
	}
	std::cout << "Part 1 : " << world.activeCubesGet() << "\n";
    });

    bench([&input]() {
	World world(input, true);
	for (int cycle = 1; cycle <= 6; cycle++) {
	    world.nextCycle();
	}
	std::cout << "Part 2 : " << world.activeCubesGet() << "\n";
    });
}
