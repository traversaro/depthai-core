#include "depthai/pipeline/node/Sync.hpp"

namespace dai {
namespace node {

Sync::Sync(const std::shared_ptr<PipelineImpl>& par, int64_t nodeId) : Sync(par, nodeId, std::make_unique<Sync::Properties>()) {}
Sync::Sync(const std::shared_ptr<PipelineImpl>& par, int64_t nodeId, std::unique_ptr<Properties> props)
    : NodeCRTP<Node, Sync, SyncProperties>(par, nodeId, std::move(props)),
      inputs("inputs", Input(*this, "", Input::Type::SReceiver, {{DatatypeEnum::Buffer, true}})) {
    setInputMapRefs(&inputs);
    setOutputRefs({&out});
}

void Sync::setSyncIntervalMs(unsigned int syncIntervalMs) {
  properties.syncIntervalMs = syncIntervalMs;
}

void Sync::setSyncAttempts(unsigned int syncAttempts) {
  properties.syncAttempts = syncAttempts;
}

unsigned int Sync::getSyncIntervalMs() const {
  return properties.syncIntervalMs;
}

unsigned int Sync::getSyncAttempts() const {
  return properties.syncAttempts;
}

}  // namespace node
}  // namespace dai
