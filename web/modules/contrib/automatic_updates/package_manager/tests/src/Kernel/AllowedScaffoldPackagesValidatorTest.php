<?php

declare(strict_types=1);

namespace Drupal\Tests\package_manager\Kernel;

use Drupal\fixture_manipulator\ActiveFixtureManipulator;
use Drupal\package_manager\Event\PreApplyEvent;
use Drupal\package_manager\Event\PreCreateEvent;
use Drupal\package_manager\ValidationResult;

/**
 * @covers \Drupal\package_manager\Validator\AllowedScaffoldPackagesValidator
 * @group package_manager
 * @internal
 */
class AllowedScaffoldPackagesValidatorTest extends PackageManagerKernelTestBase {

  /**
   * Tests that the allowed-packages setting is validated during pre-create.
   */
  public function testPreCreate(): void {
    (new ActiveFixtureManipulator())->addConfig([
      'extra.drupal-scaffold.allowed-packages' => [
        "drupal/dummy_scaffolding",
        "drupal/dummy_scaffolding_2",
      ],
    ])->commitChanges();

    $result = ValidationResult::createError(
      [
        t("drupal/dummy_scaffolding"),
        t("drupal/dummy_scaffolding_2"),
      ],
      t('Any packages other than the implicitly allowed packages are not allowed to scaffold files. See <a href="https://www.drupal.org/docs/develop/using-composer/using-drupals-composer-scaffold">the scaffold documentation</a> for more information.')
    );
    $this->assertStatusCheckResults([$result]);
    $this->assertResults([$result], PreCreateEvent::class);
  }

  /**
   * Tests that the allowed-packages setting is validated during pre-apply.
   */
  public function testPreApply(): void {
    $this->getStageFixtureManipulator()
      ->addConfig([
        'extra.drupal-scaffold.allowed-packages' => [
          "drupal/dummy_scaffolding",
        ],
      ]);

    $result = ValidationResult::createError(
      [
        t("drupal/dummy_scaffolding"),
      ],
      t('Any packages other than the implicitly allowed packages are not allowed to scaffold files. See <a href="https://www.drupal.org/docs/develop/using-composer/using-drupals-composer-scaffold">the scaffold documentation</a> for more information.')
    );
    $this->assertResults([$result], PreApplyEvent::class);
  }

}
