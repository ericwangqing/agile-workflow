'''
测试文件的头部。本文件代码在项目编译前，被添加到所有测试代码（test**.ls）的最前面。这样，避免了在多个测试文件中写一样的头部。
'''
require! {should, async, _: underscore, './utils', '../bin/engine', '../bin/event-bus'}

debug = require('debug')('aw')

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

