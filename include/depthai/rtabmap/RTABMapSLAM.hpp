#pragma once

#include "depthai/pipeline/DeviceNode.hpp"
#include "depthai/pipeline/ThreadedHostNode.hpp"
#include "depthai/pipeline/datatype/Buffer.hpp"
#include "depthai/pipeline/datatype/IMUData.hpp"
#include "depthai/pipeline/datatype/ImgFrame.hpp"
#include "depthai/pipeline/datatype/MessageGroup.hpp"
#include "depthai/pipeline/datatype/TransformData.hpp"
#include "depthai/pipeline/datatype/CameraControl.hpp"
#include "depthai/pipeline/datatype/TrackedFeatures.hpp"
#include "depthai/pipeline/datatype/PointCloudData.hpp"
#include "depthai/pipeline/datatype/MessageGroup.hpp"
#include "rtabmap/core/CameraModel.h"
#include "rtabmap/core/Rtabmap.h"
#include "rtabmap/core/SensorData.h"
#include "rtabmap/core/Transform.h"
#include "rtabmap/core/LocalGrid.h"
#include "rtabmap/core/global_map/OccupancyGrid.h"

namespace dai {
namespace node {
class RTABMapSLAM : public dai::NodeCRTP<dai::node::ThreadedHostNode, RTABMapSLAM> {
   public:
    constexpr static const char* NAME = "RTABMapSLAM";

   public:
    void build();

    Input inputSync{*this, {.name="sync", .types = {{dai::DatatypeEnum::MessageGroup,true}}}};
    Input inputOdomPose{*this, {.name="odom_pose", .types={{dai::DatatypeEnum::TransformData, true}}}};

    Output transform{*this, {.name="transform", .types={{dai::DatatypeEnum::TransformData, true}}}};
    Output passthroughRect{*this, {.name="passthrough_rect", .types={{dai::DatatypeEnum::ImgFrame, true}}}};
    Output pointCloud{*this, {.name="point_cloud", .types={{dai::DatatypeEnum::PointCloudData, true}}}};
    Output occupancyMap{*this, {.name="map", .types={{dai::DatatypeEnum::ImgFrame, true}}}};

    void run() override;
    void stop() override;
    void setParams(const rtabmap::ParametersMap& params);
    void syncCB(std::shared_ptr<dai::ADatatype> data);
    void odomPoseCB(std::shared_ptr<dai::ADatatype> data);
   private:
    void imuCB(std::shared_ptr<dai::ADatatype> msg);
    void getCalib(dai::Pipeline& pipeline, int instanceNum, int width, int height);
    rtabmap::StereoCameraModel model;
    rtabmap::Rtabmap rtabmap;
    rtabmap::Transform currPose, odomCorrection;
    bool reuseFeatures;
    std::chrono::steady_clock::time_point lastProcessTime; 
    std::chrono::steady_clock::time_point startTime;
    rtabmap::Transform imuLocalTransform;
    rtabmap::Transform localTransform;
    rtabmap::LocalGridCache localMaps;
    rtabmap::OccupancyGrid* grid;
    float alphaScaling;
    bool modelSet = false;
    rtabmap::ParametersMap rtabParams;
    rtabmap::SensorData sensorData;
    std::string databasePath="/rtabmap.tmp.db";
    bool saveDatabase = false;
    bool publishPCL = false;
    float freq = 1.0f;
};
}  // namespace node
}  // namespace dai