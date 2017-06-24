//@ skip

function shouldBe(actual, expected) {
    if (actual !== expected)
        throw new Error('bad value: ' + actual);
}

/*
wasm/arithmetic-float64.wasm is generated by pack-asmjs <https://github.com/WebAssembly/polyfill-prototype-1> from the following script:

function asmModule(global, env, buffer) {
    "use asm";

    var abs = global.Math.abs;
    var ceil = global.Math.ceil;
    var floor = global.Math.floor;
    var sqrt = global.Math.sqrt;
    var cos = global.Math.cos;
    var sin = global.Math.sin;
    var tan = global.Math.tan;
    var acos = global.Math.acos;
    var asin = global.Math.asin;
    var atan = global.Math.atan;
    var atan2 = global.Math.atan2;
    var exp = global.Math.exp;
    var log = global.Math.log;
    var pow = global.Math.pow;
    var min = global.Math.min;
    var max = global.Math.max;

    function number() {
        return 4.2;
    }

    function negate(x) {
        x = +x;
        return -x;
    }

    function add(x, y) {
        x = +x;
        y = +y;
        return x + y;
    }

    function subtract(x, y) {
        x = +x;
        y = +y;
        return x - y;
    }

    function multiply(x, y) {
        x = +x;
        y = +y;
        return x * y;
    }

    function divide(x, y) {
        x = +x;
        y = +y;
        return x / y;
    }

    function modulo(x, y) {
        x = +x;
        y = +y;
        return x % y;
    }

    function absolute(x) {
        x = +x;
        return abs(x);
    }

    function ceilNumber(x) {
        x = +x;
        return ceil(x);
    }

    function floorNumber(x) {
        x = +x;
        return floor(x);
    }

    function squareRoot(x) {
        x = +x;
        return sqrt(x);
    }

    function cosine(x) {
        x = +x;
        return cos(x);
    }

    function sine(x) {
        x = +x;
        return sin(x);
    }

    function tangent(x) {
        x = +x;
        return tan(x);
    }

    function arccosine(x) {
        x = +x;
        return acos(x);
    }

    function arcsine(x) {
        x = +x;
        return asin(x);
    }

    function arctangent(x) {
        x = +x;
        return atan(x);
    }

    function arctangent2(x, y) {
        x = +x;
        y = +y;
        return atan2(x, y);
    }

    function exponential(x) {
        x = +x;
        return exp(x);
    }

    function logarithm(x) {
        x = +x;
        return log(x);
    }

    function power(x, y) {
        x = +x;
        y = +y;
        return pow(x, y);
    }

    function minimum(x, y, z) {
        x = +x;
        y = +y;
        z = +z;
        return min(x, y, z);
    }

    function maximum(x, y, z) {
        x = +x;
        y = +y;
        z = +z;
        return max(x, y, z);
    }

    return {
        number: number,
        negate: negate,
        add: add,
        subtract: subtract,
        multiply: multiply,
        divide: divide,
        modulo: modulo,
        absolute: absolute,
        ceilNumber: ceilNumber,
        floorNumber: floorNumber,
        squareRoot: squareRoot,
        cosine: cosine,
        sine: sine,
        tangent: tangent,
        arccosine: arccosine,
        arcsine: arcsine,
        arctangent: arctangent,
        arctangent2: arctangent2,
        exponential: exponential,
        logarithm: logarithm,
        power: power,
        minimum: minimum,
        maximum: maximum,
    };
}
*/

var module = loadWebAssembly("wasm/arithmetic-float64.wasm");

shouldBe(module.number(), 4.2);
shouldBe(module.negate(0.1), -0.1);
shouldBe(module.add(0.1, 0.5), 0.6);
shouldBe(isNaN(module.add(0.1, NaN)), true);
shouldBe(module.add(0.1, Infinity), Infinity);
shouldBe(isNaN(module.add(Infinity, -Infinity)), true);
shouldBe(module.subtract(0.1, 0.5), -0.4);
shouldBe(module.multiply(0.1, 0.5), 0.05);
shouldBe(module.divide(0.1, 0.5), 0.2);
shouldBe(module.divide(0.1, 0), Infinity);
shouldBe(module.divide(0.1, -0), -Infinity);
shouldBe(module.modulo(0.1, 0.03), 0.010000000000000009);
shouldBe(isNaN(module.modulo(0.1, 0)), true);
shouldBe(module.absolute(-4.2), 4.2);
shouldBe(module.absolute(4.2), 4.2);
shouldBe(module.ceilNumber(4.2), 5);
shouldBe(module.floorNumber(4.2), 4);
shouldBe(module.squareRoot(0.09), 0.3);
shouldBe(module.cosine(Math.PI), -1);
shouldBe(module.sine(Math.PI / 2), 1);
shouldBe(module.tangent(Math.PI / 4), 0.9999999999999999);
shouldBe(module.arccosine(-1), Math.PI);
shouldBe(module.arcsine(1), Math.PI / 2);
shouldBe(module.arctangent(1), Math.PI / 4);
shouldBe(module.arctangent2(1, 0), Math.PI / 2);
shouldBe(module.exponential(1), Math.E);
shouldBe(module.logarithm(Math.E), 1);
shouldBe(module.power(4, 1.5), 8);
shouldBe(module.minimum(0.1, -0.2, 0.3), -0.2);
shouldBe(module.maximum(0.1, -0.2, 0.3), 0.3);