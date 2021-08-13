FactoryBot.define do
  factory :task do
    title { "Test title" }
    content { "example,example,example" } 
    deadline { 1.week.after }
    status { "対応中" }
  end
end