assert = require 'assert'

mod = require '../src/index.coffee'

describe 'index section', ()->
  describe 'basic coffee-script pass', ()->
    it 'a = 1', ()->
      res = mod.compile "a = 1"
      assert.strictEqual res, """
      (function() {
        var a;
      
        a = 1;
      
      }).call(this);
      
      """
      return
    it '###a = 1###', ()->
      res = mod.compile """
        ###
        a = 1
        ###
      """
      assert.strictEqual res, """
      
      /*
      a = 1
       */
      
      (function() {
      
      
      }).call(this);
      
      """
      return
    it '`a = 1`', ()->
      res = mod.compile """
        `a = 1`
      """
      assert.strictEqual res, """
      (function() {
        a = 1;
      
      
      }).call(this);
      
      """
      return
    it 'if a then b else c', ()->
      res = mod.compile """
        if a then b else c
      """
      assert.strictEqual res, """
      (function() {
        if (a) {
          b;
        } else {
          c;
        }
      
      }).call(this);
      
      """
      return
    it 'res = if a then b else c', ()->
      res = mod.compile """
        res = if a then b else c
      """
      assert.strictEqual res, """
      (function() {
        var res;
      
        res = a ? b : c;
      
      }).call(this);
      
      """
      return
    it '{}', ()->
      res = mod.compile """
        {}
      """
      assert.strictEqual res, """
      (function() {
        ({});
      
      }).call(this);
      
      """
      return
    it '->', ()->
      res = mod.compile """
        ->
      """
      assert.strictEqual res, """
      (function() {
        (function() {});
      
      }).call(this);
      
      """
      return
    it 'loop a = 1', ()->
      res = mod.compile """
        loop
          a = 1
      """
      assert.strictEqual res, """
      (function() {
        var a;
      
        while (true) {
          a = 1;
        }
      
      }).call(this);
      
      """
      return
  
  describe 'com-lang specific', ()->
    describe 'need add arrow case', ()->
      it 'a -> 1', ()->
        res = mod.compile """
        a 
          1
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              return 1;
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a -> 1 <- b = 1', ()->
        res = mod.compile """
        a 
          1
        b = 1
        """
        assert.strictEqual res, """
        (function() {
          var b;
        
          a((function(_this) {
            return function() {
              return 1;
            };
          })(this));
        
          b = 1;
        
        }).call(this);
        
        """
        return
      it 'a -> 1 2', ()->
        res = mod.compile """
        a
          1
          2
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              1;
              return 2;
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a -> b -> 1 2', ()->
        res = mod.compile """
        a
          b
            1
            2
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              return b(function() {
                1;
                return 2;
              });
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a -> b', ()->
        res = mod.compile """
        a
          b
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              return b(function() {});
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a -> b c', ()->
        res = mod.compile """
        a
          b
          c
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              b(function() {});
              return c(function() {});
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a -> b c \\n', ()->
        res = mod.compile """
        a
          b
          c
        
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              b(function() {});
              return c(function() {});
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a -> b \\n c', ()->
        res = mod.compile """
        a
          b
          
          c
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              b(function() {});
              return c(function() {});
            };
          })(this));
        
        }).call(this);
        
        """
        return
    describe 'arrow present case', ()->
      it 'a -> 1', ()->
        res = mod.compile """
        a =>
          1
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              return 1;
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a -> 1 2', ()->
        res = mod.compile """
        a =>
          1
          2
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              1;
              return 2;
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a -> b -> 1 2', ()->
        res = mod.compile """
        a =>
          b =>
            1
            2
        """
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {
              return b(function() {
                1;
                return 2;
              });
            };
          })(this));
        
        }).call(this);
        
        """
        return
    describe 'params', ()->
      it 'a {} -> 1', ()->
        res = mod.compile """
        a {}
          1
        """
        assert.strictEqual res, """
        (function() {
          a({}, (function(_this) {
            return function() {
              return 1;
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a {multiline} -> 1', ()->
        res = mod.compile """
        a {
        }
          1
        """
        assert.strictEqual res, """
        (function() {
          a({}, (function(_this) {
            return function() {
              return 1;
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a {b:1} -> 1', ()->
        res = mod.compile """
        a {b: 1}
          1
        """
        assert.strictEqual res, """
        (function() {
          a({
            b: 1
          }, (function(_this) {
            return function() {
              return 1;
            };
          })(this));
        
        }).call(this);
        
        """
        return
      it 'a {b:1 multiline} -> 1', ()->
        res = mod.compile """
        a {
          b: 1
        }
          1
        """
        assert.strictEqual res, """
        (function() {
          a({
            b: 1
          }, (function(_this) {
            return function() {
              return 1;
            };
          })(this));
        
        }).call(this);
        
        """
        return
  
  describe 'com-lang edge cases', ()->
    describe 'single tag case', ()->
      it 'a', ()->
        res = mod.compile """
        a
        """, {
          lone_tag_filter : true
          tag_hash : {
            A: true
          }
        }
        assert.strictEqual res, """
        (function() {
          a((function(_this) {
            return function() {};
          })(this));
        
        }).call(this);
        
        """
        return
      it 'not_a', ()->
        res = mod.compile """
        not_a
        """, {
          lone_tag_filter : true
          tag_hash : {
            A: true
          }
        }
        assert.strictEqual res, """
        (function() {
          not_a;
        
        
        }).call(this);
        
        """
        return
  
  describe 'API', ()->
    it 'compile a=1', ()->
      res = mod.compile "a = 1"
      assert.strictEqual res, """
      (function() {
        var a;
      
        a = 1;
      
      }).call(this);
      
      """
      return
    
    it 'run global.a=1', ()->
      global.a = 0
      res = mod.run "global.a = 1"
      assert.strictEqual global.a, 1
      return
    it 'eval a=1', ()->
      res = mod.eval "a = 1"
      assert.strictEqual res, 1
      return
    it 'preprocess a -> b', ()->
      res = mod.preprocess """
        a
          b
      """
      assert.strictEqual res, """
      a =>
        b =>
      
      """
      return
      
    
  