Feature: World consistency
  In order to maintain stable behaviors
  As a features developer
  I want, that "World" flushes between scenarios

  Background:
    Given a standard Behat project directory structure
    And a file named "features/support/env.php" with:
      """
      <?php
      require_once 'PHPUnit/Autoload.php';
      require_once 'PHPUnit/Framework/Assert/Functions.php';
      """

  Scenario: Test consistency
    Given a file named "features/steps/world_steps.php" with:
      """
      <?php

      $steps->Given('/I have entered (\d+)/', function($world, $num) {
          assertNull($world->value);
          $world->value = $num;
      });

      $steps->Then('/I must have (\d+)/', function($world, $num) {
          assertEquals($num, $world->value);
      });

      $steps->When('/I add (\d+)/', function($world, $num) {
          $world->value += $num;
      });
      """
    And a file named "features/world.feature" with:
      """
      Feature: World consistency
        In order to maintain stable behaviors
        As a features developer
        I want, that "World" flushes between scenarios

        Background:
          Given I have entered 10

        Scenario:
          Then I must have 10

        Scenario:
          When I add 3
          Then I must have 13

        Scenario Outline:
          Given I must have 10
          When I add <value>
          Then I must have <result>

          Examples:
            | value | result |
            |  5    | 15     |
            |  10   | 20     |
            |  23   | 33     |
      """
    When I run "behat -TCf progress features/world.feature"
    Then it should pass with:
      """
      .................
      
      5 scenarios (5 passed)
      17 steps (17 passed)
      """

    Scenario: Test inconsistency
      Given a file named "features/steps/world_steps.php" with:
        """
        <?php

        $steps->Given('/I have entered (\d+)/', function($world, $num) {
            assertNull($world->value);
            $world->value = $num;
        });

        $steps->Then('/I must have (\d+)/', function($world, $num) {
            assertEquals($num, $world->value);
        });

        $steps->When('/I add (\d+)/', function($world, $num) {
            $world->value += $num;
        });
        """
      And a file named "features/world.feature" with:
        """
        Feature: World consistency
          In order to maintain stable behaviors
          As a features developer
          I want, that "World" flushes between scenarios

          Background:
            Given I have entered 10

          Scenario:
            Then I must have 12

          Scenario:
            When I add 3
            Then I must have 13

          Scenario Outline:
            When I add <value>
            Then I must have <result>

            Examples:
              | value | result |
              |  5    | 15     |
              |  10   | 20     |
              |  23   | 33     |
        """
      When I run "behat -TCf progress features/world.feature"
      Then it should fail with:
        """
        .F............

        (::) failed steps (::)

        01. Failed asserting that <string:10> is equal to <string:12>.
            In step `Then I must have 12'. # features/steps/world_steps.php:10
            From scenario ***.             # features/world.feature:9

        5 scenarios (4 passed, 1 failed)
        14 steps (13 passed, 1 failed)
        """
