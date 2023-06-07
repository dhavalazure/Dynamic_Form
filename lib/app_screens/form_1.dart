import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:test2/app_constants/constants.dart';
import 'package:test2/common_utilities/common_widgets.dart';
import 'package:test2/models/checkBoxModel.dart';
import 'package:test2/models/dropdown_model.dart';
import 'package:test2/models/radio_model.dart';
import 'package:test2/models/short_text_model.dart';
import 'package:test2/models/ui_model.dart';
import 'package:test2/models/condition_model.dart' as ConditionModel;

class UserForm extends StatefulWidget {
  const UserForm({Key? key}) : super(key: key);

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {

  String? responseTxt;
  late UiModel uiModel;
  late List<Map<int , String>?> radioValue;
  late List<bool?> radioVisible,checkBoxVisible,dropDownVisible;
  late List<String?> dropDownValue;
  late List<List<bool>?> checkBoxValue;
  late List<String?> editTexts;

  final _formKey = GlobalKey<FormState>();

  bool checkCondition(
      {required bool isDependent, required List<dynamic> value}) {

    if (isDependent) {
        if(value.isEmpty)
          {
            return true;
          }
        for (int i = 0; i < value.length; i++) {
          ConditionModel.Cond conditionModel = ConditionModel.Cond.fromJson(jsonDecode(jsonEncode(value[i]).toString()));
          switch (uiModel.fields!.elementAt(conditionModel.id!).type) {
            case Constants.radio :
              {
                if (radioValue[conditionModel.id!]?.keys.elementAt(0) == conditionModel.subId) {
                  return false;
                }
              }
              break;

            case Constants.checkBox :
              {
                if (dropDownValue[conditionModel.id!] == "null" ||
                    radioValue[conditionModel.id!] == "false") {
                  return false;
                }
              }
              break;
          }
        }
        return true;
    }
    return true;
  }

  Widget buildShortText(int idx)
  {
    ShortTextModel shortTextModel = ShortTextModel.fromJson(jsonDecode(responseTxt!)['fields'].elementAt(idx)["ob"]);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        validator: (val){
          if(shortTextModel.validation!.length!.first > -1){
            if(val!.isEmpty){
              return "Please Enter Data";
            }
            else if(shortTextModel.validation!.length!.first > val.length || shortTextModel.validation!.length!.last < val.length){
              return "Please Enter Value Between ${shortTextModel.validation!.length!.first} to ${shortTextModel.validation!.length!.last}";
            }
            else{
              return null;
            }
          }
          else{
            if(shortTextModel.validation!.length!.last > -1 && shortTextModel.validation!.length!.last < val!.length){
              return "Max ${shortTextModel.validation!.length!.last} characters required !";
            }
            else{
              return null;
            }
          }
        } ,
        decoration: InputDecoration(
          label: Text(shortTextModel.label!)
        ),
        onChanged: (value){
          editTexts[idx] = value;
        },
      ),
    );
  }

  Widget buildRadio(int idx)
   {
    print(jsonDecode(responseTxt!)['fields'].elementAt(idx)["ob"]);
    RadioModel radioModel = RadioModel.fromJson(jsonDecode(responseTxt!)['fields'].elementAt(idx)["ob"]);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for(int i = 0 ; i < radioModel.values!.length ; i++)
              Visibility(
                visible: checkCondition(isDependent : radioModel.dependent ?? false, value: radioModel.values!.elementAt(i).cond ?? []),
                child: Row(
                  children: [
                    Radio(
                        toggleable: true,
                        value: radioModel.values!.elementAt(i).value , groupValue: radioValue.elementAt(idx)!.values.elementAt(0), onChanged: (value){
                        setState(() {
                          radioValue[idx] = {
                            i : value.toString()
                          };
                        });
                    }),
                    Text(radioModel.values!.elementAt(i).value!)
                  ],
                ),
              )
          ],
        ),
        Visibility(
          visible: radioVisible[idx]!,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(10,0,0,0),
            child: Text("Please Choose One",style: TextStyle(color: Colors.red),),
          ),
        )
      ],
    );
  }

  Widget buildDropDown(int idx)
  {
    print(jsonDecode(responseTxt!)['fields'].elementAt(idx)["ob"]);
    DropDownModel dropDownModel = DropDownModel.fromJson(jsonDecode(responseTxt!)['fields'].elementAt(idx)["ob"]);


    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton(
          hint: const Text('Please choose a location'), // Not necessary for Option 1
          value: dropDownValue.elementAt(idx),
          onChanged: (newValue) {
            setState(() {
              dropDownValue[idx] = newValue;
            });
          },
          items: dropDownModel.values?.map((c) => c.value).toList().map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(location!),
            );
          }).toList(),
        ),
        Visibility(
          visible: dropDownVisible[idx]!,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10,0,0,0),
            child: Text("Please Choose one",style: TextStyle(color: Colors.red),),
          ),
        )
      ],
    );
  }

  Widget buildCheckBox(int idx)
  {
    CheckBoxModel checkBoxModel = CheckBoxModel.fromJson(jsonDecode(responseTxt!)['fields'].elementAt(idx)["ob"]);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for(int i = 0 ; i < checkBoxModel.values!.length ; i++)
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.blue,
                    value: checkBoxValue.elementAt(idx)!.elementAt(i),
                    onChanged: (bool? value) {
                      checkBoxValue[idx]![i] = value!;
                      setState(() {});
                    },
                  ),
                  Text( checkBoxModel.values!.elementAt(i).value!)
                ],
              ),
          ],
        ),
        Visibility(
          visible: checkBoxVisible[idx]!,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10,0,0,0),
            child: Text("Please Choose between ${checkBoxModel.validation!.minCheck!} to ${checkBoxModel.validation!.maxCheck!}",style: TextStyle(color: Colors.red),),
          ),
        )
      ],
    );
  }

  loadJson() async
  {
    responseTxt = await rootBundle.loadString("assets/form.json");
    uiModel = UiModel.fromJson(jsonDecode(responseTxt!));
    radioValue = List.generate(uiModel.fields!.length , (index) => null);
    radioVisible = List.generate(uiModel.fields!.length , (index) => false);
    checkBoxVisible = List.generate(uiModel.fields!.length , (index) => false);
    dropDownVisible = List.generate(uiModel.fields!.length , (index) => false);
    dropDownValue = List.generate(uiModel.fields!.length , (index) => null);
    checkBoxValue  = List.generate(uiModel.fields!.length, (index) => null);
    editTexts  = List.generate(uiModel.fields!.length, (index) => null);
    uiModel.fields!.forEach((element) {

       if(element.type == Constants.radio)
         {
           radioValue.insert(element.id!, {
             -1 : "null"
           });
         }
       else if(element.type == Constants.checkBox)
       {
         CheckBoxModel checkBoxModel = CheckBoxModel.fromJson(element.ob!.toJson());
         checkBoxValue.insert(element.id!, List.generate(checkBoxModel.values!.length, (index) => false));
       }
       else if(element.type == Constants.dropDown)
       {
         dropDownValue.insert(element.id!, null);
       }
    });
    setState(() {});
    print(uiModel.fields!.length);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadJson();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: responseTxt == null ? Container() : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ListView.builder(
                shrinkWrap: true,
                  itemCount: uiModel.fields!.length,
                  itemBuilder: (ctx , i){
                    switch(uiModel.fields!.elementAt(i).type)
                    {
                      case Constants.shortText : return buildShortText(i);
                      case Constants.radio : return buildRadio(i);
                      case Constants.checkBox : return buildCheckBox(i);
                      case Constants.dropDown : return buildDropDown(i);
                      default : return Container();
                    }
                  }),
              ElevatedButton(
                  onPressed: (){
                    for(int i= 0; i <uiModel.fields!.length ; i++)
                    {
                      log("- ${uiModel.fields!.elementAt(i).type}");
                      switch(uiModel.fields!.elementAt(i).type)
                      {
                        case Constants.shortText : {
                          log("Text is ${editTexts.elementAt(i)}");
                        }
                        break;
                        case Constants.radio : {

                          RadioModel radioModel = RadioModel.fromJson(jsonDecode(responseTxt!)['fields'].elementAt(i)["ob"]);
                          if(radioModel.validation!.isMandatory != null && radioModel.validation!.isMandatory!)
                            {
                              if(radioValue[i] == "null")
                              {
                                  radioVisible[i] = true;
                                  setState(() {});
                                  //CommonWidgets.showToast("Please select item !");
                              }
                              else
                                {
                                  radioVisible[i] = false;
                                  setState(() {});
                                  log("Radio is ${radioValue[i]}");
                                }
                            }
                        }
                        break;
                        case Constants.checkBox : {
                          log("chckbox ${checkBoxValue.elementAt(i).toString()}");
                          int selectedCount = 0;
                          CheckBoxModel checkboxModel = CheckBoxModel.fromJson(jsonDecode(responseTxt!)['fields'].elementAt(i)["ob"]);
                          for(int index = 0; index < checkBoxValue.elementAt(i)!.length; index++){
                            if(checkBoxValue.elementAt(i)![index] == true){
                              selectedCount++;
                            }
                          }
                          if(checkboxModel.validation!.minCheck! <= selectedCount  && selectedCount <= checkboxModel.validation!.maxCheck!){
                            checkBoxVisible[i] = false;
                            setState(() {});
                          }
                          else{
                            checkBoxVisible[i] = true;
                            setState(() {});
                          }
                        }
                        break;
                        case Constants.dropDown : {
                          DropDownModel dropDownModel = DropDownModel.fromJson(jsonDecode(responseTxt!)['fields'].elementAt(i)["ob"]);
                          if(dropDownModel.validation!.isMandatory != null && dropDownModel.validation!.isMandatory!)
                          {
                            if(dropDownValue[i] == null)
                            {
                              dropDownVisible[i] = true;
                              setState(() {});
                            }
                            else
                            {
                              dropDownVisible[i] = false;
                              setState(() {});
                            }
                          }
                        }
                        break;
                        default : log("");
                      }
                    }
                    if(_formKey.currentState!.validate())
                    {
                      if(!radioVisible.contains(true) && !checkBoxVisible.contains(true) && !dropDownVisible.contains(true)){
                        CommonWidgets.showToast("All Done!!!!!!!");
                      }
                    }
              },
                  child: const Text("Submit"))
            ],
          ),
        )),
    );
  }
}
