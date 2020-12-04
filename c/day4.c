#include <assert.h>
#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FIELD_CNT 8

typedef int (*is_valid_fn)(const char *val);

typedef struct passport {
    uint8_t      valid;
    const char * val[FIELD_CNT];
} passport_t;

const char * ecls[] = {
    "amb", "blu", "brn", "gry", "grn", "hzl", "oth", NULL
};

int check_byr(const char *val) {
    int n = atoi(val);
    return n >= 1920 && n <= 2002;
}

int check_iyr(const char *val) {
    int n = atoi(val);
    return n >= 2010 && n <= 2020;
}

int check_eyr(const char *val) {
    int n = atoi(val);
    return n >= 2020 && n <= 2030;
}

int check_hgt(const char *val) {
    const char *suffix = val + strlen(val) - 2;
    int height = atoi(val);
    return (strcmp(suffix, "in") == 0 && height >= 59 && height <= 76)
        || (strcmp(suffix, "cm") == 0 && height >= 150 && height <= 193);
}

int check_hcl(const char *val) {
    const char *v = val + 1;
    if (strlen(val) != 7 || *val != '#') {
        return 0;
    }
    while (v - val < 7) {
        if (!isxdigit(*v++)) {
            return 0;
        }
    }
    return 1;
}

int check_ecl(const char *val) {
    size_t i = 0;
    while (ecls[i] != NULL && strcmp(ecls[i], val) != 0) {
        i++;
    }
    return ecls[i] != NULL;
}

int check_pid(const char *val) {
    const char *v = val;
    while (*v && isdigit(*v)) {
        v++;
    }
    return v - val == 9;
}

int check_cid(const char *val) {
    return 1;
}

const struct {
    const char *repr;
    is_valid_fn is_valid;
} field_map[] = {
    { "byr", check_byr },
    { "iyr", check_iyr },
    { "eyr", check_eyr },
    { "hgt", check_hgt },
    { "hcl", check_hcl },
    { "ecl", check_ecl },
    { "pid", check_pid },
    { "cid", check_cid },
};

size_t passport_cnt(char *input) {
    size_t cnt = 0;
    size_t offset = 0;
    while (input[offset] != '\0') {
        if (input[offset] == '\n' && input[offset+1] == '\n') {
            input[offset] = '\0';
            cnt++;
        }
        offset++;
    }
    return cnt + 1;
}

uint8_t field_idx(const char *repr) {
    for (uint8_t i = 0; i < FIELD_CNT; i++) {
        if (strncmp(field_map[i].repr, repr, 3) == 0) {
            return i;
        }
    }
    assert(0);
    return 0;
}

passport_t passport_make(char **req) {
    passport_t passport;
    size_t req_len = strlen(*req);

    memset(&passport, 0, sizeof passport);
    for (char *tok = strtok(*req, " \n"); tok != NULL; tok = strtok(NULL, " \n")) {
        uint8_t id = field_idx(tok);
        passport.val[id] = tok + 4;
        passport.valid |= (1 << id);
    }
    *req = *req + req_len + 1;
    return passport;
}

passport_t * passports_make(char *input, size_t *cnt) {
    *cnt = passport_cnt(input);
    passport_t * passports = calloc(sizeof(passport_t), *cnt);

    for (size_t i = 0; i < *cnt; i++) {
        passports[i] = passport_make(&input);
    }

    return passports;
}

char * input_get() {
    FILE *f = fopen("input.txt", "r");
    fseek(f, 0, SEEK_END);
    size_t f_len = ftell(f);
    char *input = calloc(1, f_len + 1);
    rewind(f);
    fread(input, f_len, 1, f);
    fclose(f);
    return input;
}

size_t valid_1(const passport_t *passports, size_t cnt) {
    size_t n = 0;
    for (size_t i = 0; i < cnt; i++) {
        n += (passports[i].valid & 0x7f) == 0x7f;
    }
    return n;
}

size_t valid_2(const passport_t *passports, size_t cnt) {
    size_t n = 0;
    for (size_t i = 0; i < cnt; i++) {
        int valid = (passports[i].valid & 0x7f) == 0x7f;
        const passport_t *p = passports + i;
        for (uint8_t field = 0; field < FIELD_CNT; field++) {
            if (p->valid & (1 << field)) {
                valid &= field_map[field].is_valid(p->val[field]);
            }
        }
        n += valid;
    }
    return n;
}

int main() {
    char *input = input_get();
    size_t num_passports;
    passport_t * passports = passports_make(input, &num_passports);

    printf("Part 1 : %ld\n", valid_1(passports, num_passports));
    printf("Part 2 : %ld\n", valid_2(passports, num_passports));

    free(passports);
    free(input);
}
