<?php

namespace phpnomad\Dev\Tests\Integration\Tests;

use phpnomad\Dev\Tests\Integration\TestCase;

class TestWordPressLoads extends TestCase
{
	public function testWordPressFunctionsExist()
	{
		$this->assertTrue(function_exists('do_action'));
	}
}