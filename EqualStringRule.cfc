/*
   Copyright 2012 Neo Neo

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

component EqualStringRule extends="StringRule" {

	public boolean function test(required struct data) {

		var value = getValue(arguments.data);
		var compareValue = getParameterValue(arguments.data);

		return compareValues(value, compareValue);
	}

	public string function script() {

		var leftValue = "data.#variables.fieldName#";
		var rightValue = "(#variables.parameter.script()#)(data)";
		if (!variables.caseSensitive) {
			leftValue &= ".toLowerCase()";
			rightValue &= ".toLowerCase()";
		}

		return "
			function (data) {
				return #leftValue# === #rightValue#;
			}
		";
	}

}