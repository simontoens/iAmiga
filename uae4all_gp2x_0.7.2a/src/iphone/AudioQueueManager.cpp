/*
 Frodo, Commodore 64 emulator for the iPhone
 Copyright (C) 2007, 2008 Stuart Carnie
 See gpl.txt for license information.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "AudioQueueManager.h"
#include "RingQ.h"
#include <libkern/OSAtomic.h>
#import <stdatomic.h>

const int kMinimumBufferSize = 1920;

CAudioQueueManager::CAudioQueueManager(float sampleFrequency, int sampleFrameCount, SoundChannels channels)
:_sampleFrequency(sampleFrequency), _sampleFrameCount(sampleFrameCount), _samplesInQueue(0), _runLoop(NULL), _soundThread(NULL),
_autoDelete(true)
{
	_dataFormat.mSampleRate = sampleFrequency;
	_dataFormat.mFormatID = kAudioFormatLinearPCM;
	_dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	_dataFormat.mBytesPerPacket = 2 * channels;
	_dataFormat.mBytesPerFrame = 2 * channels;
	_dataFormat.mFramesPerPacket = 1;
	_dataFormat.mChannelsPerFrame = channels;
	_dataFormat.mBitsPerChannel = 16;
	
	_soundQBuffer.AllocateBuffers(16, _sampleFrameCount);
	
	_bytesPerQueueBuffer = _bytesPerFrame = _sampleFrameCount * _dataFormat.mBytesPerFrame;
	if (_bytesPerFrame < kMinimumBufferSize) {
		_framesPerBuffer = kMinimumBufferSize / _bytesPerFrame;
		if (kMinimumBufferSize % _bytesPerFrame != 0)
			_framesPerBuffer++;
			
		_bytesPerFrame = _framesPerBuffer * _bytesPerFrame;
	} else
		_framesPerBuffer = 1;
}

CAudioQueueManager::~CAudioQueueManager() {
	
}

void CAudioQueueManager::start(bool autoStart) {
	if (_soundThread != NULL) {
		printf("Thread is already running");
		return;
	}
	
	_autoStart = autoStart;
	
	pthread_attr_t theThreadAttributes;
	
	OSStatus result = pthread_attr_init(&theThreadAttributes);
	result = pthread_attr_setdetachstate(&theThreadAttributes, PTHREAD_CREATE_DETACHED);
	result = pthread_create(&_soundThread, &theThreadAttributes, (ThreadRoutine)CAudioQueueManager::Entry, this);
	pthread_attr_destroy(&theThreadAttributes);
}

void CAudioQueueManager::stop() {
	if (_soundThread == NULL) {
		return;
	}
	CFRunLoopStop(_runLoop);
}

void* CAudioQueueManager::Entry(CAudioQueueManager* inAudioQueueManager) {
	inAudioQueueManager->execute();
	return NULL;
}

void CAudioQueueManager::execute() {
	setupQueue();
	_runLoop = CFRunLoopGetCurrent();
	
	CFRunLoopRun();
	
	shutdownQueue();
	
	_soundThread = NULL;
	if (_autoDelete)
		delete this;
}

void CAudioQueueManager::setupQueue() {
	OSStatus res = AudioQueueNewOutput(&_dataFormat, HandleOutputBuffer, this, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_queue);
	for (int i = 0; i < kNumberBuffers; i++) {
		res = AudioQueueAllocateBuffer(_queue, _bytesPerFrame, &_buffers[i]);
		HandleOutputBuffer(this, _queue, _buffers[i]);
	}
	
	if (_autoStart) {
		_isRunning = true;
		res = AudioQueueStart(_queue, NULL);
	}
	
	_isInitialized = true;
}

void CAudioQueueManager::setVolume(float volume) {
    AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, volume);
}

float CAudioQueueManager::getVolume() {
    float volume;
    AudioQueueGetParameter(_queue, kAudioQueueParam_Volume, &volume);
    return volume;
}

void CAudioQueueManager::shutdownQueue() {
	if (_isRunning) {
		_isRunning = false;
		AudioQueueDispose(_queue, TRUE);
	}
}

short* CAudioQueueManager::getNextBuffer() {
	return _soundQBuffer.DequeueFreeBuffer();
}

void CAudioQueueManager::queueBuffer(short* buffer) {
	_soundQBuffer.EnqueueSoundBuffer(buffer);
    atomic_fetch_add(&_samplesInQueue, _sampleFrameCount);
}

void CAudioQueueManager::pause() {
	if (!_isRunning || !_isInitialized)
		return;
	
	AudioQueuePause(_queue);
	_isRunning = false;
}

void CAudioQueueManager::resume() {
	if (_isRunning)
		return;
	
	if (!_isInitialized) {
		_autoStart = true;
		return;
	}
	
	AudioQueueStart(_queue, NULL);
	_isRunning = true;
}

void CAudioQueueManager::HandleOutputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef outBuffer) {
	CAudioQueueManager *aq = (CAudioQueueManager*)aqData;
	aq->_HandleOutputBuffer(outBuffer);
}

void CAudioQueueManager::_HandleOutputBuffer(AudioQueueBufferRef outBuffer) {
	if (!_isRunning || _soundQBuffer.SoundCount() == 0) {
		outBuffer->mAudioDataByteSize = outBuffer->mAudioDataBytesCapacity;
        bzero(outBuffer->mAudioData, outBuffer->mAudioDataBytesCapacity);
	} else {
		
		int neededFrames = _framesPerBuffer;
		unsigned char* buf = (unsigned char*)outBuffer->mAudioData;
		int bytesInBuffer = 0;

		for ( ; _soundQBuffer.SoundCount() && neededFrames; neededFrames--) {
			short* buffer = _soundQBuffer.DequeueSoundBuffer();
			memcpy(buf, buffer, _bytesPerQueueBuffer);
			_soundQBuffer.EnqueueFreeBuffer(buffer);
            atomic_fetch_add(&_samplesInQueue, -_sampleFrameCount);
			buf += _bytesPerQueueBuffer;
			bytesInBuffer += _bytesPerQueueBuffer;
		}
		
		outBuffer->mAudioDataByteSize = bytesInBuffer;
#if defined(DEBUG_SOUND)
		if (outBuffer->mAudioDataByteSize == 0)
			printf("audio buffer underrun.");
		else if (outBuffer->mAudioDataByteSize < outBuffer->mAudioDataBytesCapacity) 
			printf("audio buffer less than capacity %u < %u.", (unsigned int)outBuffer->mAudioDataByteSize, (unsigned int)outBuffer->mAudioDataBytesCapacity);
#endif
	}
	
	OSStatus res = AudioQueueEnqueueBuffer(_queue, outBuffer, 0, NULL);
	if (res != 0)
		throw "Unable to enqueue buffer";
}
