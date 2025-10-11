package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"

	"github.com/prometheus/prometheus/model/rulefmt"
	"go.yaml.in/yaml/v4"
)

// Precompile regular expressions
var (
	reSpacesAfterParen  = regexp.MustCompile(`\(\s+`)
	reSpacesBeforeParen = regexp.MustCompile(`\s+\)`)
	reMultipleSpaces    = regexp.MustCompile(`\s+`)
)

// NormalizeExpression normalizes the given expression string
func NormalizeExpression(expr string) string {
	expr = strings.ReplaceAll(expr, "\n", " ")
	expr = strings.TrimSpace(expr) // Strip leading and trailing spaces

	// Remove spaces after '(' and before ')'
	expr = reSpacesAfterParen.ReplaceAllString(expr, "(")
	expr = reSpacesBeforeParen.ReplaceAllString(expr, ")")

	// Replace multiple spaces with a single space
	expr = reMultipleSpaces.ReplaceAllString(expr, " ")

	return expr
}

// ValidateAndNormalizeGroups validates and normalizes rules inside rule groups
func ValidateAndNormalizeGroups(ruleGroups *rulefmt.RuleGroups) {
	for i, group := range ruleGroups.Groups {
		var validRules []rulefmt.Rule

		for _, rule := range group.Rules {
			rule.Expr = NormalizeExpression(rule.Expr)

			if errs := rule.Validate(rulefmt.RuleNode{}); len(errs) == 0 {
				validRules = append(validRules, rule)
			} else {
				logInvalidRule(fmt.Sprintf("Skipping invalid rule in group '%s': %s\n", group.Name, rule.Expr))
			}
		}
		ruleGroups.Groups[i].Rules = validRules
	}
}

// logInvalidRule logs the invalid rule message
func logInvalidRule(message string) {
	if os.Getenv("GITHUB_ACTIONS") == "true" {
		fmt.Fprintf(os.Stderr, "::warning::%s", message)
	} else {
		fmt.Fprint(os.Stderr, message)
	}
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: <program> <input_file>")
		os.Exit(1)
	}

	inputFile := os.Args[1]

	ruleGroups, errs := rulefmt.ParseFile(inputFile, false)
	if errs != nil {
		fmt.Printf("Error parsing file: %v\n", errs)
		os.Exit(1)
	}

	ValidateAndNormalizeGroups(ruleGroups)

	// Print the result to stdout
	output, err := yaml.Marshal(&ruleGroups)
	if err != nil {
		fmt.Printf("Failed to marshal YAML: %v\n", err)
	} else {
		fmt.Println(string(output))
	}
}
