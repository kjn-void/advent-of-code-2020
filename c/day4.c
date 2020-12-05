#include <assert.h>
#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    BYR, IYR, EYR, HGT, HCL, ECL, PID, CID, NUM_FIELDS
} field_id_t;

const char * fields[] = {
    "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"
};

const char * ecls[] = {
    "amb", "blu", "brn", "gry", "grn", "hzl", "oth", NULL
};

typedef struct {
    const char * fields[NUM_FIELDS];
} passport_t;

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
    while (v - val < 7) {
        if (!isxdigit(*v++)) {
            return 0;
        }
    }
    return *val == '#';
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

field_id_t field_id(const char *repr) {
    for (field_id_t i = 0; i < NUM_FIELDS; i++) {
        if (strncmp(fields[i], repr, strlen(fields[i])) == 0) {
            return i;
        }
    }
    assert(0);
    return -1;
}

void passport_make(passport_t *passport, char **req) {
    size_t req_len = strlen(*req);

    for (char *tok = strtok(*req, " \n"); tok != NULL; tok = strtok(NULL, " \n")) {
        passport->fields[field_id(tok)] = tok + 4;
    }
    *req = *req + req_len + 1;
}

passport_t * passports_make(char *input, size_t *cnt) {
    *cnt = passport_cnt(input);
    passport_t * passports = calloc(sizeof(passport_t), *cnt);

    for (size_t i = 0; i < *cnt; i++) {
        passport_make(passports + i, &input);
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

int check_fields(const passport_t *passport) {
    for (field_id_t i = 0; i < CID; i++) {
        if (passport->fields[i] == NULL) {
            return 0;
        }
    }
    return 1;
}

size_t valid_1(const passport_t *passport, ssize_t idx) {
    return idx < 0 ? 0
        : check_fields(passport) + valid_1(passport + 1, idx - 1);
}

size_t valid_2(const passport_t *passport, ssize_t idx) {
    return idx < 0 ? 0
        : (valid_2(passport + 1, idx - 1)
           + (check_fields(passport)
              && check_byr(passport->fields[BYR])
              && check_iyr(passport->fields[IYR])
              && check_eyr(passport->fields[EYR])
              && check_hgt(passport->fields[HGT])
              && check_hcl(passport->fields[HCL])
              && check_ecl(passport->fields[ECL])
              && check_pid(passport->fields[PID])));
}

int main() {
    char *input = input_get();
    size_t num_passports;
    passport_t * passports = passports_make(input, &num_passports);

    printf("Part 1 : %ld\n", valid_1(passports, num_passports - 1));
    printf("Part 2 : %ld\n", valid_2(passports, num_passports - 1));

    free(passports);
    free(input);
}
