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

component ValidRule extends="Rule" {

	public void function init(required string type) {
		variables.type = arguments.type;
	}

	public boolean function test(required struct data) {

		var result = false;
		var value = getValue(arguments.data);

		switch (variables.type) {

			case "integer":
			case "numeric":
				if (LSIsNumeric(value)) {
					value = LSParseNumber(value);
				}
				result = StructKeyExists(local, "value") && IsValid(variables.type, value);
				if (result) {
					"arguments.data._cvalid.#variables.fieldName#" = value;
				}
				break;

			case "boolean":
			case "creditcard":
			case "email":
			case "guid":
			case "string":
			case "url":
				result = IsValid(variables.type, value);
				break;

			case "time":
				value = ListChangeDelims(value, ":", "."); // also accept . as a delimiter
			case "date":
			case "datetime":
				if (LSIsDate(value)) {
					result = true;
					value = LSParseDateTime(value);
				}
				if (result) {
					"arguments.data._cvalid.#variables.fieldName#" = value;
				}
				break;

			case "website":
				result = IsValid("url", value) && REFind("^http[s]?://", value) == 1;
				break;

			case "color":
				result = IsValid("regex", value,"^([0-9A-Fa-f]){6}$");
				break;

		}

		return result;
	}

}