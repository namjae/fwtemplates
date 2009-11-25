MyTestCase = TestCase ("MyTestCase");

MyTestCase.prototype.testA = function () {
  expectAsserts (1);
  assertSame ("my car", MyLib.dude (0));
};
