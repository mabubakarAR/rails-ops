require "test_helper"

class JobApplicationMailerTest < ActionMailer::TestCase
  test "new_application_notification" do
    mail = JobApplicationMailer.new_application_notification
    assert_equal "New application notification", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "status_update_notification" do
    mail = JobApplicationMailer.status_update_notification
    assert_equal "Status update notification", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
