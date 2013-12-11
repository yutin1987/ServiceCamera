//
//  Configs.h
//  ServiceCamera
//
//  Created by Justin on 13/3/17.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#ifndef ServiceCamera_configs_h
#define ServiceCamera_configs_h

const static CGSize SCPicSize = {480, 320};

// Output
float const SCVideoTrans = 1.5;
float const SCVideoStay = 3;
float const SCVideoFrame = 60;

// List
const static CGSize SCThumbSize = {132, 133};
const float SCThumbPadding = 4;
const float SCThumbMargin = 18;
const float SCThumbRadius = 10;
const float SCThumbTitle = 20;
const float SCThumbNote = 20;
const float SCThumbTextPadding = 20;
const static CGSize SCMoodSize = {42, 42};
const static CGSize SCPenSize = {42, 35};
const static CGSize SCInputTextSize = {23, 41};
const static CGSize SCInputDescribeSize = {23, 109};

// Print
const float SCPrintScale = 3;

// View
const static CGSize SCTextInputSize = {23, 41};
const static CGSize SCNoteSize = {480, 42};
const float SCNoteTextSize = 28;

// Btn
const static CGSize SCBtnSize = {43, 39};
const static CGSize SCBtnSwitchSize = {43, 27};

#define SCFont @"HelveticaNeue-Bold"

#define SCFileMood @"mood_%d.png"

#define SCFileOriginal @"img_%d.jpeg"
#define SCFileOutput @"img_output_%d.jpeg"
#define SCFileVideo @"output.mp4"

#define SCTableImgs @"CREATE TABLE IF NOT EXISTS imgs (pid integer primary key asc autoincrement, mood integer, note varchar(255), hide integer)"

#endif
