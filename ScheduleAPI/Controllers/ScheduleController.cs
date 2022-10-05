
using Microsoft.AspNetCore.Mvc;
using Repository.models;
using Repository.Repository.Interface;
using ScheduleAPI.Models.Requests;

namespace AttendanceManagementAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ScheduleController : Controller
    {
        private readonly IFlatScheduleRepository _scheduleRepository;

        public ScheduleController(IFlatScheduleRepository scheduleRepository)
        {
            _scheduleRepository = scheduleRepository;
        }


        [HttpGet]
        public List<ScheduleResponse> GetSchedule([FromQuery] DateTime Date)
        {
            var scheduleRequest = new ScheduleRequest();
            scheduleRequest.ScheduleDate = Date;

            var resp = _scheduleRepository.Get<ScheduleRequest>(scheduleRequest, "[dbo].[Schedule_Get]");
            return resp;
        }
    }
}
