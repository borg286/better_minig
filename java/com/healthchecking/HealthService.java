package healthchecking;

import io.grpc.health.v1.HealthCheckRequest;
import io.grpc.health.v1.HealthCheckResponse;
import io.grpc.health.v1.HealthGrpc;
import io.grpc.stub.StreamObserver;
import java.util.concurrent.Callable;

public class HealthService extends HealthGrpc.HealthImplBase {

    private Callable<Boolean> checker;
    public static HealthService service;

    public HealthService(Callable<Boolean> checker) {
        this.checker = checker;
        service = this;
    }

    @Override
    public void check(HealthCheckRequest request, StreamObserver<HealthCheckResponse> responseObserver) {
        try {
            if (checker.call()) {
                responseObserver.onNext(
                        HealthCheckResponse.newBuilder().setStatus(HealthCheckResponse.ServingStatus.SERVING).build()
                );
            } else {
                responseObserver.onNext(
                        HealthCheckResponse.newBuilder().setStatus(HealthCheckResponse.ServingStatus.NOT_SERVING).build()
                );
            }
        } catch (Exception ex) {
            System.out.println("Failed Healch Check");
        } finally {
            responseObserver.onCompleted();
        }
    }
}
