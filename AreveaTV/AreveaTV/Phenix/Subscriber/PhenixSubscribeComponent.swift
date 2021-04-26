/*
 * Copyright 2019 Phenix Real Time Solutions, Inc. Confidential and Proprietary. All Rights Reserved.
 *
 * By using this code you agree to the Phenix Terms of Service found online here:
 * http://phenixrts.com/terms-of-service.html
 */

import UIKit
import PhenixSdk


/**
 * Class contains all logic to subscribe to a channel
 */
public class PhenixSubscribeComponent {
    
    public struct Configuration {
        var channelAlias: String
        // realtime is default
        var capability: SubscribeCapability?
    }
    
    private let channelExpress: PhenixChannelExpress
   // private let channelId = "us-west#arevea.com#3631619168007739MultiCreatorEventFinalVerification.464kK0AQ4ehy"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    init(channelExpress: PhenixChannelExpress) {
        self.channelExpress = channelExpress
    }
    
    /**
     * Prepare required configuration to subcscribe channel
     */
    private func prepareNativeConfiguration(configuration: Configuration, playerView: UIView!) -> PhenixJoinChannelOptions {
        let subscribeCapability = configuration.capability == nil ? [String]() : [configuration.capability!.rawValue]
        
        let joinRoomOptions = PhenixRoomExpressFactory.createJoinRoomOptionsBuilder()
            .withRoomAlias(configuration.channelAlias)
            .withRole(PhenixMemberRole.audience)
            .withRoomId(appDelegate.phenixChannelId)
            .withCapabilities(subscribeCapability)
            .buildJoinRoomOptions()
        
        
        let renderLayer = playerView.layer
        
        let rendererOptions = PhenixRendererOptions()
        rendererOptions.aspectRatioMode = .letterbox
        
        let joinChannelOptions = PhenixChannelExpressFactory.createJoinChannelOptionsBuilder()
            .withJoinRoomOptions(joinRoomOptions)
            // Select the most recent stream. Viewing stream changes any time a new stream starts in the room.
            //.withStreamSelectionStrategy(.mostRecent)
            // Alternatively you can use high availability if you are using multiple simultaneous publishers.
            .withStreamSelectionStrategy(.highAvailability)
            .withRendererOptions(rendererOptions)
            .withRenderer(renderLayer)
            .buildJoinChannelOptions()
        
        return joinChannelOptions!
    }
    
    public func subscribe(configuration: Configuration, playerView: UIView, subscribeCallback: OnSubscribeCallback) {
        
        assert(Thread.current.isMainThread, "Needs to be called from main thread")
        
        let options = prepareNativeConfiguration(configuration: configuration, playerView: playerView)
        let pcastExpress : PhenixPCastExpress = AppDelegate.channelExpress.pcastExpress as! PhenixPCastExpress
        let renderLayer = playerView.layer

        channelExpress.joinChannel(options, { (joinStatus, roomService) in // first of all, we should connect channel
            // Callbacks will be returned from worker thread.
            // For UI operations better to wrap it in mainthread
            DispatchQueue.main.async {
                switch(joinStatus) {
                case .ok: // we joined channel
                    //AppDelegate.channelExpress.pcastExpress.pcast.subscribe("token",SubscribeCallback(
                    let subscribeOptions = PhenixPCastExpressFactory.createSubscribeOptionsBuilder()
                        .withStreamId(self.appDelegate.phenixChannelId)
                        .withStreamToken(self.appDelegate.phenixAccessToken1)
                        .withCapabilities(["real-time"])
                        .withRenderer(renderLayer)
                        .buildSubscribeOptions()
                    pcastExpress.subscribe(subscribeOptions)
                    {
                        (status: PhenixRequestStatus, subscriber: PhenixExpressSubscriber?, renderer: PhenixRenderer?) in
                        if status == .ok {
                            // Do something with subscriber
                            subscribeCallback.onJoinChannelSuccess(roomService: roomService!)

                            if let renderer = renderer {
                              // Returned if `withRenderer...` option was enabled - Do something with renderer
                            }
                          } else {
                            // Handle error
                          }
                        subscribeCallback.onJoinChannelSuccess(roomService: roomService!)
                    }
                /*  MyApplication.pCastExpress.getPCast().subscribe(token, new PCast.SubscribeCallback() {
                 @Override
                 public void onEvent(PCast pCast, RequestStatus requestStatus, MediaStream mediaStream) {
                 callback.onJoinChannelSuccess(roomService);
                 }
                 });
                 */
                default: // something went wrong
                    subscribeCallback.onError(error: .joinChannel(status: joinStatus))
                }
            }
        }) { (suscribeStatus, subscriber, renderer) in // then we could subscribe to it conten
            // Callbacks will be returned from worker thread.
            // For UI operations better to wrap it in mainthread
            DispatchQueue.main.async {
                switch(suscribeStatus) {
                case .ok: // we subscribed.
                    subscribeCallback.onSubscribeSuccess(subscriber: subscriber!, renderer: renderer!)
                case .noStreamPlaying: // we subscribed, but there is no active content for playback
                    subscribeCallback.onNoActiveStream()
                default: // something went wrong
                    subscribeCallback.onError(error: .subscribeChannel(status: suscribeStatus))
                }
            }
        }
    }
    
}

public extension PhenixRequestStatus {
    func getLocalisedStatusMessage() -> String {
        switch self {
        case .ok: return NSLocalizedString("PhenixRequestStatusOk", comment: "")
        case .noStreamPlaying: return NSLocalizedString("PhenixRequestStatusNoStreamPlaying", comment: "")
        case .badRequest: return NSLocalizedString("PhenixRequestStatusBadRequest", comment: "")
        case .unauthorized: return NSLocalizedString("PhenixRequestStatusUnauthorized", comment: "")
        case .conflict: return NSLocalizedString("PhenixRequestStatusConflict", comment: "")
        case .gone: return NSLocalizedString("PhenixRequestStatusGone", comment: "")
        case .notInitialized: return NSLocalizedString("PhenixRequestStatusNotInitialized", comment: "")
        case .notStarted: return NSLocalizedString("PhenixRequestStatusNotStarted", comment: "")
        case .upgradeRequired: return NSLocalizedString("PhenixRequestStatusUpgradeRequired", comment: "")
        case .failed: return NSLocalizedString("PhenixRequestStatusFailed", comment: "")
        case .capacity: return NSLocalizedString("PhenixRequestStatusCapacity", comment: "")
        case .timeout: return NSLocalizedString("PhenixRequestStatusTimeout", comment: "")
        case .notReady: return NSLocalizedString("PhenixRequestStatusNotReady", comment: "")
        case .rateLimited: return NSLocalizedString("PhenixRequestStatusRateLimited", comment: "")
        }
    }
}
