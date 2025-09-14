FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { 'job_seeker' }

    trait :admin do
      role { 'admin' }
    end

    trait :company do
      role { 'company' }
    end

    trait :job_seeker do
      role { 'job_seeker' }
    end
  end

  factory :company do
    association :user, factory: [:user, :company]
    name { Faker::Company.name }
    description { Faker::Company.catch_phrase }
    website { Faker::Internet.url }
    industry { Faker::Company.industry }
    size { Company.sizes.keys.sample }
    founded_year { rand(1800..2020) }
    headquarters { Faker::Address.city }

    trait :with_jobs do
      after(:create) do |company|
        create_list(:job, 3, company: company)
      end
    end
  end

  factory :job_seeker do
    association :user, factory: [:user, :job_seeker]
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { '+1234567890' }
    location { Faker::Address.city }
    bio { Faker::Lorem.paragraph }
    experience_years { rand(0..20) }

    trait :with_applications do
      after(:create) do |job_seeker|
        create_list(:job_application, 3, job_seeker: job_seeker)
      end
    end
  end

  factory :category do
    name { Faker::Job.field }
    description { Faker::Lorem.sentence }

    trait :with_skills do
      after(:create) do |category|
        create_list(:skill, 5, category: category)
      end
    end
  end

  factory :skill do
    association :category
    name { Faker::ProgrammingLanguage.name }
  end

  factory :job do
    association :company
    title { Faker::Job.title }
    description { Faker::Lorem.paragraph }
    requirements { Faker::Lorem.paragraph }
    benefits { Faker::Lorem.paragraph }
    location { Faker::Address.city }
    salary_min { rand(30000..80000) }
    salary_max { rand(80000..150000) }
    employment_type { Job.employment_types.keys.sample }
    remote { [true, false].sample }
    status { Job.statuses.keys.sample }

    trait :active do
      status { 'active' }
    end

    trait :draft do
      status { 'draft' }
    end

    trait :with_categories do
      after(:create) do |job|
        job.categories << create_list(:category, 2)
      end
    end
  end

  factory :job_application do
    association :job
    association :job_seeker
    cover_letter { Faker::Lorem.paragraph(3) }
    status { JobApplication.statuses.keys.sample }
    applied_at { Faker::Time.between(from: 30.days.ago, to: Time.current) }

    trait :pending do
      status { 'pending' }
    end

    trait :accepted do
      status { 'accepted' }
    end

    trait :rejected do
      status { 'rejected' }
    end
  end

  factory :job_category do
    association :job
    association :category
  end

  factory :job_seeker_skill do
    association :job_seeker
    association :skill
    proficiency_level { JobSeekerSkill.proficiency_levels.keys.sample }
  end
end
