/*
* Copyright (c) 2018 elementary LLC. (https://github.com/elementary/calculator)
*
* This file is part of Pantheon Calculator
*
* Pantheon Calculator is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Pantheon Calculator is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Pantheon Calculator. If not, see http://www.gnu.org/licenses/.
*/

class PantheonCalculator.Core.CoreTest : Object {
    public static int main (string[] args) {

        assert_equal ("0+0", "0");
        assert_equal ("2+2", "4");
        assert_equal ("4.23 + 1.11", "5.34");
        assert_equal ("25.123 - 234.2", "-209.077");

        assert_equal ("1*1", "1");
        assert_equal ("11 * 1.1", "12.1");
        assert_equal ("5 × -1", "-5"); // https://github.com/elementary/calculator/issues/37
        assert_equal ("5 × -2", "-10"); // https://github.com/elementary/calculator/issues/37
        assert_equal ("-5 * -1", "5"); // https://github.com/elementary/calculator/issues/37
        assert_equal ("-5 * -2", "10"); // https://github.com/elementary/calculator/issues/37
        assert_equal ("-1 / −1", "1"); // https://github.com/elementary/calculator/pull/38/files
        assert_equal ("144 / 15", "9.6");
        assert_equal ("144000 / 12", "12000");

        assert_equal ("2^5", "32");
        assert_equal ("3456^0.5 - sqrt(3456)", "0");
        assert_equal ("723 mod 5", "3");
        assert_equal ("2%", "0.02");

        assert_equal ("14E-2", "0.14"); // https://github.com/elementary/calculator/issues/16
        assert_equal ("1.1E2 - 1E1", "100");

        assert_equal ("pi", "3.141592654");
        assert_equal ("(π)", "3.141592654");
        assert_equal ("e", "2.718281828");

        assert_equal ("sqrt(144)", "12");
        assert_equal ("√423", "20.566963801");
        assert_equal ("sin(pi ÷ 2)", "1");
        assert_equal ("sin(-pi)", "0"); // https://github.com/elementary/calculator/issues/1
        assert_equal ("cos(90)", "-0.448073616");
        assert_equal ("sinh(2)", "3.626860408");
        assert_equal ("cosh(2)", "3.762195691");

        assert_equal ("2 + 2 * 2.2", "6.4");
        assert_equal ("(2 + 2) * 2.2", "8.8");
        assert_equal ("sin(0.123)^2 + cos(0.123)^2", "1");
        assert_equal ("tan(0.245) - sin(0.245) / cos(0.245)", "0");
        assert_equal ("sqrt(5^2 - 4^2)", "3");
        assert_equal ("sqrt(423) + (3.23 * 8.56) - 1E2", "-51.784236199");
        assert_equal ("sqrt(-1 + 423 + 1) + (3.23 * 8.56) - sin(90 + 0.2)", "47.428606036");
        assert_equal ("e^5.25 / exp(5.25)", "1");
        assert_equal ("exp(log(2.2))", "2.2");
        assert_equal ("3.141592654*3.141592654", "9.869604404"); // https://github.com/elementary/calculator/issues/7
        assert_equal ("10 + 5 - 10%", "14.9"); // https://github.com/elementary/calculator/issues/44
        assert_equal ("10 - 10% + 5", "14.9"); // https://github.com/elementary/calculator/issues/44

        assert_throw ("2+(2", "Mismatched parenthesis.");
        assert_throw ("2+f", "'f' is invalid.");

        return 0;
    }

    static void assert_equal (string input, string result) {
        try {
            string eval_result = Evaluation.evaluate (input, 0);
            if (eval_result != result) {
                error ("%s is %s, but should be %s", input, eval_result, result);
            }
        } catch (Error e) {
            error ("Exception at input %s", input);
        }
    }

    static void assert_throw (string input, string message) {
        Error eval_error = null;
        try {
            Evaluation.evaluate (input, 0);
        } catch (Error e) {
            eval_error = e;
        }

        if (eval_error == null) {
            error ("%s did not throw", input);
        } else if (eval_error.message != message) {
            error ("%s did throw %s, but should %s", input, eval_error.message, message);
        }
    }
}
