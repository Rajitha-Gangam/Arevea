/*
 * Copyright 2019 Phenix Real Time Solutions, Inc. Confidential and Proprietary. All Rights Reserved.
 *
 * By using this code you agree to the Phenix Terms of Service found online here:
 * http://phenixrts.com/terms-of-service.html
 */

import PhenixSdk


/**
 * Interface to handle subscribe events
 */
public protocol OnSubscribeCallback {

    /**
     * Triggers after you joined the channel. Please save roomService in your local link.
     *
     * - Parameter roomService: service object to control current room session
     */
    func onJoinChannelSuccess(roomService: PhenixRoomService);

    /**
     * Triggers each time after we subscribed to a stream. Playback is imminent.
     *
     * - Parameter subscriber: subscriber to current channel stream
     * - Parameter renderer: Current channel stream player
     */
    func onSubscribeSuccess(subscriber: PhenixExpressSubscriber, renderer: PhenixRenderer);

    /**
     * Channel is joined, but there is no active stream.
     * Will auto subscribe when stream becomes available
     */
    func onNoActiveStream();

    /**
     * Triggers when an error occurred during joining or subscribing
     *
     * - Parameter error: related error
     */
    func onError(error: SubscribeError);
}


public enum SubscribeError: Error {

    case joinChannel(status: PhenixRequestStatus)
    case subscribeChannel(status: PhenixRequestStatus)
}
