Review assigner
=======================

Finds an optimal expert-to-object assignment given the following conditions:

1. There are objects to review by experts.
2. Each object must be reviewed by exactly given number of experts.
3. Expert can review a single object only once.
4. Expert has some pre-paid amount of reviews.
5. There are already some expert-to-object assignments.
6. Some experts allow to have over contract reviews, some ones don't.
7. We need to use as few experts as possible.
8. We should find as few new experts as possible (second criteria).

Time complexity of solution: `O(|Objects| |Experts| log(|Objects|))`

## Install

```
gem install review_assigner
```
or add it to your Gemfile:
```ruby
gem 'review_assigner', '~> 0.0', github: 'jughead/review_assigner'
```
and run `bundle install`

## Usage

You can either use command line:
```
bundle exec review_assigner <input_filename> <output_filename>
```
`input_filename` is any string value suitable for `roo` gem.
`output_filename` is a path to store xlsx result.


or use it internally:
```ruby
ReviewAssigner.assign_excel(input_filename, output_filename)
```

