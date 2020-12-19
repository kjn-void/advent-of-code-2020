#include <chrono>
#include <fstream>
#include <functional>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>
#include <tuple>
#include <unordered_map>
#include <vector>

struct IRule;

using RuleId = int;
using Rule = std::shared_ptr<IRule>;

struct IRule {
    virtual std::vector<std::string> apply(const std::string &msg,
					   const std::vector<Rule> &rules) const = 0;
};

class Letter : public IRule {
    char ch;
public:
    Letter(char letter) : ch(letter) { }

    std::vector<std::string> apply(const std::string &msg,
				   const std::vector<Rule> &rules) const override {
	if (ch == msg[0]) {
	    return std::vector<std::string>{msg.substr(1)};
	}
	return std::vector<std::string>();
    }
};

class Sequence : public IRule {
    std::vector<RuleId> sequence;
public:
    Sequence(const std::vector<RuleId> &seq) : sequence(seq) { }

    std::vector<std::string> apply(const std::string &msg,
				   const std::vector<Rule> &rules) const override {
	std::vector<std::string> rems{msg};
	for (auto rule_id: sequence) {
	    const Rule &rule = rules[rule_id];
	    std::vector<std::string> res;
	    for (auto &m: rems) {
		for (auto new_m: rule->apply(m, rules)) {
		    res.push_back(new_m);
		}
	    }
	    rems = res;
	}
	return rems;
    }
};

class Choice : public IRule {
    std::vector<Rule> choices;
public:
    Choice(const std::vector<Rule> &c) : choices(c) { }

    std::vector<std::string> apply(const std::string &msg,
				   const std::vector<Rule> &rules) const override {
	std::vector<std::string> rems;
	for (auto &rule: choices) {
	    for (auto &m: rule->apply(msg, rules)) {
		rems.push_back(m);
	    }
	}
	return rems;
    };
};

Rule make_rule(const std::string &repr) {
    if (repr[0] == '"') {
	return std::make_shared<Letter>(repr[1]);
    }

    auto pos = repr.find('|');
    if (pos == std::string::npos) {
	std::stringstream ss(repr);
	std::vector<RuleId> rule_ids;
	RuleId rule_id;
	while (ss >> rule_id) {
	    rule_ids.push_back(rule_id);
	}
	return std::make_shared<Sequence>(rule_ids);
    }

    return std::make_shared<Choice>(std::vector<Rule>{
	    make_rule(repr.substr(0, pos)),
	    make_rule(repr.substr(pos+1))});
}

bool match(const std::string &message,
	   const std::vector<Rule> &rules) {
    auto ms = rules[0]->apply(message, rules);
    for (auto &m: ms) {
	if (m.length() == 0) {
	    return true;
	}
    }
    return false;
}

void bench(std::function<void()> fn) {
    auto start = std::chrono::steady_clock::now();
    fn();
    auto finish = std::chrono::steady_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(finish - start);
    std::cout << "Took : " << duration.count() << "ms\n";
}

std::tuple<std::vector<Rule>, std::vector<std::string>>
parseInput(const std::string &fn) {
    std::fstream fin(fn);
    std::string line;
    std::unordered_map<int, Rule> id_rule_map;

    while (std::getline(fin, line) && line != "") {
	RuleId id = std::stoi(line);
	id_rule_map[id] = make_rule(line.substr(line.find(' ') + 1));
    }

    std::vector<std::string> messages;
    while (std::getline(fin, line)) {
	messages.push_back(line);
    }

    auto highest_rule_id = std::max_element(id_rule_map.begin(),
					    id_rule_map.end(),
					    [](auto &a, auto &b){ return a.first < b.first; });
    std::vector<Rule> rules;
    rules.resize(highest_rule_id->first + 1);

    for (auto &id_rule: id_rule_map) {
	rules[id_rule.first] = id_rule.second;
    }

    return std::make_tuple(rules, messages);
}

int count_valid_messages(const std::vector<std::string> &messages,
                         const std::vector<Rule> &rules) {
    int cnt = 0;

#pragma omp parallel for reduction(+:cnt)
    for (int i = 0; i < messages.size(); i++) {
        if (match(messages[i], rules)) {
            cnt++;
        }
    }

    return cnt;
}

int main() {
    std::vector<Rule> rules;
    std::vector<std::string> messages;
    std::tie(rules, messages) = parseInput("input.txt");

    bench([&]() {
	std::cout << "Part 1 : "
		  << count_valid_messages(messages, rules)
		  << '\n';
    });

    rules[8] = make_rule("42 | 42 8");
    rules[11] = make_rule("42 31 | 42 11 31");

    bench([&]() {
	std::cout << "Part 2 : "
		  << count_valid_messages(messages, rules)
		  << '\n';
    });
}
