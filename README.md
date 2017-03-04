# AMShyBar
![img](https://github.com/CoderAMing/AMShyBar/blob/master/amshybar.gif)
* Import ```UIViewController+AMShyBar.h``` in your controller
* 实现以下2个方法

```- (void)viewWillDisappear:(BOOL)animated
{
[super viewWillDisappear:animated];
[self am_expand];
}```

* 确保viewController释放的时候stop scrolling

```- (void)dealloc 
{
[self am_stopFollowingScrollView]
}```
...
