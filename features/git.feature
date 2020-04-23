Feature: git
  puppet-blacksmith needs to commit and tag git sources

  Scenario: Tagging and commiting
    Given I run `git clone https://github.com/voxpupuli/puppet-blacksmith-integration-test .`
    And I run `git checkout -b test v2.0.0`
    When I run `git tag`
    Then the output should not match /^v2\.0\.1$/
    Given a file named "Rakefile" with:
    """
    require 'puppetlabs_spec_helper/rake_tasks'
    require "#{__dir__}/../../lib/puppet_blacksmith/rake_tasks"
    """
    And a file named "metadata.json" with:
    """
    {
      "name": "puppet-blacksmith-integration-test",
      "version": "2.0.1",
      "dependencies": []
    }
    """
    When I run `rake module:tag module:bump_commit`
    Then the exit status should be 0
    And the file "metadata.json" should contain:
    """
    {
      "name": "puppet-blacksmith-integration-test",
      "version": "2.0.2",
      "dependencies": [

      ]
    }
    """
    When I run `git tag`
    Then the output should match /^v2\.0\.1$/
    When I run `git show --format=%s`
    Then the output should match /^\[blacksmith\] Bump version to 2\.0\.2$/
    When I run `git describe`
    Then the output should match /^fatal: No annotated tags can describe/

  Scenario: Tagging and commiting in a path with spaces
    Given a directory named "path with spaces"
    When I cd to "path with spaces"
    Given I run `git clone https://github.com/voxpupuli/puppet-blacksmith-integration-test .`
    And I run `git checkout -b test v2.0.0`
    When I run `git tag`
    Then the output should not match /^v2\.0\.1$/
    Given a file named "Rakefile" with:
    """
    require 'puppetlabs_spec_helper/rake_tasks'
    require "#{__dir__}/../../../lib/puppet_blacksmith/rake_tasks"
    """
    And a file named "metadata.json" with:
    """
    {
      "name": "puppet-blacksmith-integration-test",
      "version": "2.0.1",
      "dependencies": []
    }
    """
    When I run `rake module:tag module:bump_commit`
    Then the exit status should be 0
    And the file "metadata.json" should contain:
    """
    {
      "name": "puppet-blacksmith-integration-test",
      "version": "2.0.2",
      "dependencies": [

      ]
    }
    """
    When I run `git tag`
    Then the output should match /^v2\.0\.1$/
    When I run `git show --format=%s`
    Then the output should match /^\[blacksmith\] Bump version to 2\.0\.2$/

  Scenario: Tagging and commiting with custom patterns
    Given I run `git clone https://github.com/voxpupuli/puppet-blacksmith-integration-test .`
    And I run `git checkout -b test v2.0.0`
    When I run `git tag`
    Then the output should not match /^2\.0\.1$/
    Given a file named "Rakefile" with:
    """
    require 'puppetlabs_spec_helper/rake_tasks'
    require "#{__dir__}/../../lib/puppet_blacksmith/rake_tasks"
    Blacksmith::RakeTask.new do |t|
      t.tag_pattern = "%s"
      t.tag_message_pattern = "Version %s"
      t.commit_message_pattern = "New version %s"
    end
    """
    And a file named "metadata.json" with:
    """
    {
      "name": "puppet-blacksmith-integration-test",
      "version": "2.0.1",
      "dependencies": []
    }
    """
    When I run `rake module:tag module:bump_commit`
    Then the exit status should be 0
    And the file "metadata.json" should contain:
    """
    {
      "name": "puppet-blacksmith-integration-test",
      "version": "2.0.2",
      "dependencies": [

      ]
    }
    """
    When I run `git tag`
    Then the output should match /^2\.0\.1$/
    And the output should not match /^v2\.0\.1$/
    When I run `git show --format=%s`
    Then the output should match /^New version 2\.0\.2$/
    When I run `git describe`
    Then the output should match /^2\.0\.1$/
